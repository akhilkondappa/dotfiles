import AppKit

enum Mode { case daemon, send, stop }

var mode: Mode = .daemon
var agent = "kiro"
var snippet = ""
var session = ""
var window = ""

var args = CommandLine.arguments.dropFirst().makeIterator()
while let arg = args.next() {
    switch arg {
    case "--daemon":  mode = .daemon
    case "--send":    mode = .send
    case "--stop":    mode = .stop
    case "--agent":   agent = args.next() ?? agent
    case "--snippet": snippet = args.next() ?? snippet
    case "--session": session = args.next() ?? session
    case "--window":  window = args.next() ?? window
    default: break
    }
}

switch mode {
case .stop:
    let n = Notification(type: "stop", agent: "", snippet: "", session: "", window: "")
    _ = Daemon.send(n)
    exit(0)

case .send:
    guard !session.isEmpty, !window.isEmpty else {
        fputs("Usage: kiro-hud --send --agent <name> --snippet <text> --session <s> --window <w>\n", stderr)
        exit(1)
    }
    let n = Notification(type: "notify", agent: agent, snippet: snippet, session: session, window: window)

    // Try sending to existing daemon
    if Daemon.send(n) { exit(0) }

    // Daemon not running — start it, then retry
    let selfPath = CommandLine.arguments[0]
    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: selfPath)
    proc.arguments = ["--daemon"]
    try? proc.run()

    // Wait for socket to appear
    for _ in 0..<20 {
        usleep(100_000) // 100ms
        if Daemon.send(n) { exit(0) }
    }
    fputs("kiro-hud: failed to start daemon\n", stderr)
    exit(1)

case .daemon:
    // Check if already running
    let testNotification = Notification(type: "notify", agent: "ping", snippet: "", session: "x", window: "x")
    if Daemon.send(testNotification) {
        // Already running
        exit(0)
    }

    let app = NSApplication.shared
    app.setActivationPolicy(.regular)

    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: HUDWindowController!
    var daemon: Daemon!

    func applicationDidFinishLaunching(_ notification: Foundation.Notification) {
        let config = Config.load()
        controller = HUDWindowController(config: config)

        daemon = Daemon(
            onNotification: { [weak self] n in
                guard n.agent != "ping" else { return } // ignore health checks
                let tab = TabState(agent: n.agent, snippet: n.snippet, session: n.session, window: n.window)
                self?.controller.addTab(tab)
            },
            onStop: { [weak self] in
                self?.daemon.stop()
                NSApp.terminate(nil)
            }
        )

        do {
            try daemon.start()
        } catch {
            fputs("kiro-hud: daemon failed to start: \(error)\n", stderr)
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ notification: Foundation.Notification) {
        daemon?.stop()
    }
}
