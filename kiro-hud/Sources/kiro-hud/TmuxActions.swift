import Foundation

enum TmuxActions {
    static func sendReply(_ text: String, window: String) {
        // Escape single quotes in the reply
        let escaped = text.replacingOccurrences(of: "'", with: "'\\''")
        run("/usr/local/bin/tmux", args: ["send-keys", "-t", window, escaped, "Enter"])
    }

    static func jumpToWindow(session: String, window: String) {
        run("/usr/bin/open", args: ["-a", "Ghostty"])
        run("/usr/local/bin/tmux", args: ["switch-client", "-t", session])
        run("/usr/local/bin/tmux", args: ["select-window", "-t", window])
    }

    @discardableResult
    private static func run(_ cmd: String, args: [String]) -> Bool {
        // Try /usr/local/bin first, then /opt/homebrew/bin
        var executable = cmd
        if !FileManager.default.fileExists(atPath: cmd) {
            let brew = cmd.replacingOccurrences(of: "/usr/local/bin/", with: "/opt/homebrew/bin/")
            executable = FileManager.default.fileExists(atPath: brew) ? brew : cmd
        }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: executable)
        p.arguments = args
        p.standardOutput = FileHandle.nullDevice
        p.standardError = FileHandle.standardError
        try? p.run()
        p.waitUntilExit()
        return p.terminationStatus == 0
    }
}
