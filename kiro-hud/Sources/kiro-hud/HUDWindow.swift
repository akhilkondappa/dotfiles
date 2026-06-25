import AppKit
import SwiftUI

// NSPanel subclass that can always become key (required for text input in borderless windows)
class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class HUDWindowController: NSObject {
    private var panel: KeyablePanel?
    private let config: Config
    private let hudWidth: CGFloat = 360

    init(config: Config) {
        self.config = config
    }

    func show(agent: String, snippet: String, session: String, window: String) {
        guard let screen = NSScreen.main else { return }
        let margin: CGFloat = 16
        let estimatedHeight: CGFloat = snippet.isEmpty ? 140 : 200

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

        let p = KeyablePanel(
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

        // Activate app + make panel key after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
            p.makeKeyAndOrderFront(nil)
            // Find and focus the NSTextField
            if let textField = self.findTextField(in: p.contentView) {
                p.makeFirstResponder(textField)
            }
        }

        // Slide in
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            p.animator().setFrame(finalRect, display: true)
        }

        // Dismiss on click outside (delayed to avoid self-trigger)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                guard let self, let panel = self.panel else { return }
                if !panel.frame.contains(NSEvent.mouseLocation) {
                    self.dismiss()
                }
            }
        }

        // ESC key
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { self?.dismiss() }
            return event
        }
    }

    private func findTextField(in view: NSView?) -> NSTextField? {
        guard let view else { return nil }
        if let tf = view as? NSTextField, tf.isEditable { return tf }
        for sub in view.subviews {
            if let found = findTextField(in: sub) { return found }
        }
        return nil
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
