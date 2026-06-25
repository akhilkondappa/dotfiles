import Foundation

enum TmuxActions {
    static func sendReply(_ text: String, window: String) {
        let escaped = text.replacingOccurrences(of: "\\", with: "\\\\")
        run("tmux", args: ["send-keys", "-t", window, escaped, "Enter"])
    }

    static func jumpToWindow(session: String, window: String) {
        run("open", args: ["-a", "Ghostty"])
        run("tmux", args: ["switch-client", "-t", session])
        run("tmux", args: ["select-window", "-t", window])
    }

    @discardableResult
    private static func run(_ name: String, args: [String]) -> Bool {
        guard let path = resolvePath(name) else {
            fputs("kiro-hud: command not found: \(name)\n", stderr)
            return false
        }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.standardError
        do {
            try p.run()
            p.waitUntilExit()
            return p.terminationStatus == 0
        } catch {
            fputs("kiro-hud: failed to run \(path): \(error)\n", stderr)
            return false
        }
    }

    private static func resolvePath(_ name: String) -> String? {
        let searchPaths = ["/opt/homebrew/bin", "/usr/local/bin", "/usr/bin", "/bin"]
        for dir in searchPaths {
            let full = "\(dir)/\(name)"
            if FileManager.default.isExecutableFile(atPath: full) { return full }
        }
        return nil
    }
}
