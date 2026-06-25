import AppKit
import SwiftUI

class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
class HUDWindowController: ObservableObject {
    @Published var tabs: [TabState] = []
    @Published var activeTabId: UUID? = nil
    @Published var isExpanded = false

    private var panel: KeyablePanel?
    private let config: Config
    private let hudWidth: CGFloat = 360

    init(config: Config) {
        self.config = config
    }

    func addTab(_ tab: TabState) {
        tabs.append(tab)
        activeTabId = tab.id
        if panel == nil { showWindow() }
        else { updateContent(); activateWindow() }
    }

    func removeTab(_ id: UUID) {
        tabs.removeAll { $0.id == id }
        if tabs.isEmpty {
            hideWindow()
        } else {
            if activeTabId == id { activeTabId = tabs.last?.id }
            updateContent()
        }
    }

    func removeAllTabs() {
        tabs.removeAll()
        hideWindow()
    }

    func selectTab(_ id: UUID) {
        activeTabId = id
        if let idx = tabs.firstIndex(where: { $0.id == id }) {
            tabs[idx].isRead = true
        }
        updateContent()
    }

    func toggleExpand() {
        isExpanded.toggle()
        guard let p = panel, let screen = NSScreen.main else { return }
        let margin: CGFloat = 16
        let screenFrame = screen.visibleFrame

        let targetRect: NSRect
        if isExpanded {
            let panelWidth = max(hudWidth, screenFrame.width * 0.2)
            targetRect = NSRect(x: screenFrame.maxX - panelWidth - margin, y: screenFrame.minY + margin,
                                width: panelWidth, height: screenFrame.height - margin * 2)
        } else {
            targetRect = compactRect(screen: screen)
        }

        updateContent()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            p.animator().setFrame(targetRect, display: true)
        }
    }

    private func showWindow() {
        guard let screen = NSScreen.main else { return }
        let rect = compactRect(screen: screen)
        let startRect = NSRect(x: rect.origin.x, y: rect.origin.y - 30, width: rect.width, height: rect.height)

        let p = KeyablePanel(contentRect: startRect, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        p.level = .floating
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        p.isMovable = false

        self.panel = p
        updateContent()
        p.orderFront(nil)

        // Slide in
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            p.animator().setFrame(rect, display: true)
        }

        activateWindow()
    }

    private func hideWindow() {
        guard let p = panel else { return }
        self.panel = nil
        isExpanded = false
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.2
            p.animator().alphaValue = 0
        }, completionHandler: {
            p.orderOut(nil)
        })
    }

    private func activateWindow() {
        guard let p = panel else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
            p.makeKeyAndOrderFront(nil)
        }
    }

    private func updateContent() {
        guard let p = panel else { return }
        let view = HUDView(controller: self)
        p.contentView = NSHostingView(rootView: view)
    }

    private func compactRect(screen: NSScreen) -> NSRect {
        let margin: CGFloat = 16
        let sf = screen.visibleFrame
        let h: CGFloat = 240
        return NSRect(x: sf.maxX - hudWidth - margin, y: sf.minY + margin + 50, width: hudWidth, height: h)
    }
}
