import AppKit
import SwiftUI

class HUDWindowController: NSObject {
    private var panel: NSPanel?
    private let config: Config
    private let hudWidth: CGFloat = 360

    init(config: Config) {
        self.config = config
    }

    func show(agent: String, snippet: String, session: String, window: String) {
        guard let screen = NSScreen.main else { return }
        let margin: CGFloat = 16
        let estimatedHeight: CGFloat = snippet.isEmpty ? 120 : 170

        let screenFrame = screen.visibleFrame
        let finalX: CGFloat
        let finalY: CGFloat
        let startY: CGFloat

        switch config.position {
        case .bottomRight:
            finalX = screenFrame.maxX - hudWidth - margin
            finalY = screenFrame.minY + margin
            startY = finalY - estimatedHeight - 20
        case .topRight:
            finalX = screenFrame.maxX - hudWidth - margin
            finalY = screenFrame.maxY - estimatedHeight - margin
            startY = finalY + estimatedHeight + 20
        }

        let startRect = NSRect(x: finalX, y: startY, width: hudWidth, height: estimatedHeight)
        let finalRect = NSRect(x: finalX, y: finalY, width: hudWidth, height: estimatedHeight)

        let p = NSPanel(
            contentRect: startRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.level = .floating
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        p.isMovable = false

        let hudView = HUDView(
            agent: agent,
            snippet: snippet,
            session: session,
            window: window,
            dismissSeconds: config.dismissSeconds,
            onDismiss: { [weak self] in self?.dismiss() }
        )

        p.contentView = NSHostingView(rootView: hudView)
        p.orderFront(nil)

        self.panel = p

        // Slide in
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            p.animator().setFrame(finalRect, display: true)
        }

        // Dismiss on click outside
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.dismiss()
        }

        // ESC key
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { self?.dismiss() }
            return event
        }
    }

    func dismiss() {
        guard let p = panel else { return }
        self.panel = nil

        let offY: CGFloat
        switch config.position {
        case .bottomRight: offY = p.frame.origin.y - p.frame.height - 20
        case .topRight: offY = p.frame.origin.y + p.frame.height + 20
        }
        let endRect = NSRect(x: p.frame.origin.x, y: offY, width: p.frame.width, height: p.frame.height)

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.25
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            p.animator().setFrame(endRect, display: true)
            p.animator().alphaValue = 0
        }, completionHandler: {
            NSApp.terminate(nil)
        })
    }
}
