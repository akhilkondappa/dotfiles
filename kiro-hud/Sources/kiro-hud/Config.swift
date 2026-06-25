import Foundation

struct Config {
    enum Position: String { case bottomRight = "bottom-right", topRight = "top-right" }

    var position: Position = .bottomRight
    var dismissSeconds: Int = 10

    static func load() -> Config {
        var config = Config()
        let path = (("~/.config/kiro-hud/config" as NSString).expandingTildeInPath)
        let url = URL(fileURLWithPath: path)

        // Create default config if missing
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let defaults = "position=bottom-right\ndismiss_seconds=10\n"
            try? defaults.write(to: url, atomically: true, encoding: .utf8)
            return config
        }

        guard let contents = try? String(contentsOf: url) else { return config }
        for line in contents.split(separator: "\n") {
            let parts = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { continue }
            switch parts[0] {
            case "position": config.position = Position(rawValue: parts[1]) ?? .bottomRight
            case "dismiss_seconds": config.dismissSeconds = Int(parts[1]) ?? 10
            default: break
            }
        }
        return config
    }
}
