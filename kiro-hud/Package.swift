// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "kiro-hud",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "kiro-hud",
            path: "Sources/kiro-hud"
        )
    ]
)
