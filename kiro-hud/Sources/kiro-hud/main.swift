import AppKit

// Parse CLI args
var agent = "kiro"
var snippet = ""
var session = ""
var window = ""

var args = CommandLine.arguments.dropFirst()
var it = args.makeIterator()
while let arg = it.next() {
    switch arg {
    case "--agent":   agent   = it.next() ?? agent
    case "--snippet": snippet = it.next() ?? snippet
    case "--session": session = it.next() ?? session
    case "--window":  window  = it.next() ?? window
    default: break
    }
}

guard !session.isEmpty, !window.isEmpty else {
    fputs("Usage: kiro-hud --agent <name> --snippet <text> --session <name> --window <id>\n", stderr)
    exit(1)
}

let config = Config.load()

class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: HUDWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = HUDWindowController(config: config)
        controller?.show(agent: agent, snippet: snippet, session: session, window: window)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
