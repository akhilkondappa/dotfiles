import Foundation

class Daemon {
    private var serverSocket: Int32 = -1
    private var running = false
    let onNotification: (Notification) -> Void
    let onStop: () -> Void

    init(onNotification: @escaping (Notification) -> Void, onStop: @escaping () -> Void) {
        self.onNotification = onNotification
        self.onStop = onStop
    }

    func start() throws {
        let path = Config.socketPath
        // Remove stale socket
        unlink(path)

        serverSocket = socket(AF_UNIX, SOCK_STREAM, 0)
        guard serverSocket >= 0 else { throw DaemonError.socketCreate }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            path.withCString { cstr in
                _ = memcpy(ptr, cstr, min(path.utf8.count, 103))
            }
        }

        let bindResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                bind(serverSocket, sockPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard bindResult == 0 else { throw DaemonError.bindFailed }
        guard listen(serverSocket, 5) == 0 else { throw DaemonError.listenFailed }

        running = true
        Thread.detachNewThread { [weak self] in self?.acceptLoop() }
    }

    private func acceptLoop() {
        while running {
            var clientAddr = sockaddr_un()
            var len = socklen_t(MemoryLayout<sockaddr_un>.size)
            let client = withUnsafeMutablePointer(to: &clientAddr) { ptr in
                ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                    accept(serverSocket, sockPtr, &len)
                }
            }
            guard client >= 0 else { continue }
            handleClient(client)
            close(client)
        }
    }

    private func handleClient(_ fd: Int32) {
        var data = Data()
        var buf = [UInt8](repeating: 0, count: 65536)
        while true {
            let n = read(fd, &buf, buf.count)
            if n <= 0 { break }
            data.append(contentsOf: buf[0..<n])
            if buf[n-1] == 0x0A { break } // newline terminated
        }

        guard let json = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              let jsonData = json.data(using: .utf8),
              let notification = try? JSONDecoder().decode(Notification.self, from: jsonData) else { return }

        if notification.type == "stop" {
            DispatchQueue.main.async { self.onStop() }
        } else {
            DispatchQueue.main.async { self.onNotification(notification) }
        }
    }

    func stop() {
        running = false
        if serverSocket >= 0 { close(serverSocket) }
        unlink(Config.socketPath)
    }

    static func send(_ notification: Notification) -> Bool {
        let path = Config.socketPath
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return false }
        defer { close(fd) }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
            path.withCString { cstr in
                _ = memcpy(ptr, cstr, min(path.utf8.count, 103))
            }
        }

        let connectResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                connect(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard connectResult == 0 else { return false }

        guard let data = try? JSONEncoder().encode(notification),
              var json = String(data: data, encoding: .utf8) else { return false }
        json += "\n"
        _ = json.withCString { write(fd, $0, json.utf8.count) }
        return true
    }

    enum DaemonError: Error { case socketCreate, bindFailed, listenFailed }
}
