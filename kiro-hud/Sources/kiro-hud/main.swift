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
let app = NSApplication.shared
app.setActivationPolicy(.accessory) // no dock icon

let controller = HUDWindowController(config: config)

// Show HUD on main thread after app starts
DispatchQueue.main.async {
    controller.show(agent: agent, snippet: snippet, session: session, window: window)
}

app.run()
