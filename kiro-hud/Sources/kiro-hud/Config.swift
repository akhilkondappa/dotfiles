import Foundation

struct Config {
    enum Position: String { case bottomRight = "bottom-right", topRight = "top-right" }
    var position: Position = .bottomRight

    static let socketPath = (NSHomeDirectory() as NSString).appendingPathComponent(".kiro/hud.sock")

    static func load() -> Config {
        var config = Config()
        let path = (NSHomeDirectory() as NSString).appendingPathComponent(".config/kiro-hud/config")
        guard let contents = try? String(contentsOfFile: path) else { return config }
        for line in contents.split(separator: "\n") {
            let parts = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { continue }
            if parts[0] == "position" { config.position = Position(rawValue: parts[1]) ?? .bottomRight }
        }
        return config
    }
}
