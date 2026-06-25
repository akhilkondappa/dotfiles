import SwiftUI
import AppKit

// Rose Pine colors
private extension Color {
    static let rpBase       = Color(hex: "#1f1d2e")
    static let rpSurface    = Color(hex: "#26233a")
    static let rpText       = Color(hex: "#e0def4")
    static let rpMuted      = Color(hex: "#908caa")
    static let rpSubtle     = Color(hex: "#6e6a86")
    static let rpRose       = Color(hex: "#eb6f92")
    static let rpIris       = Color(hex: "#c4a7e7")
    static let rpFoam       = Color(hex: "#9ccfd8")
    static let rpHighlight  = Color(hex: "#403d52")
    static let rpOverlay    = Color(hex: "#2a2837")
}

private extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(red: Double((rgb >> 16) & 0xff) / 255,
                  green: Double((rgb >> 8) & 0xff) / 255,
                  blue: Double(rgb & 0xff) / 255)
    }
}

// Blur backdrop
struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.state = .active
        v.material = .hudWindow
        v.blendingMode = .behindWindow
        v.appearance = NSAppearance(named: .darkAqua)
        return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) {}
}

// Mouse hover tracking
struct MouseHoverView: NSViewRepresentable {
    let onHover: (Bool) -> Void
    func makeNSView(context: Context) -> NSView {
        let v = HoverView()
        v.onHover = onHover
        return v
    }
    func updateNSView(_ v: NSView, context: Context) {}
}

class HoverView: NSView {
    var onHover: ((Bool) -> Void)?
    private var trackingArea: NSTrackingArea?
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let t = trackingArea { removeTrackingArea(t) }
        trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self)
        addTrackingArea(trackingArea!)
    }
    override func mouseEntered(with event: NSEvent) { onHover?(true) }
    override func mouseExited(with event: NSEvent) { onHover?(false) }
}

// NSTextField wrapper that properly handles first responder in borderless windows
struct FocusableTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onSubmit: () -> Void
    var onFocus: (Bool) -> Void

    func makeNSView(context: Context) -> NSTextField {
        let tf = NSTextField()
        tf.placeholderString = placeholder
        tf.isBordered = false
        tf.drawsBackground = false
        tf.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        tf.textColor = NSColor(red: 224/255, green: 222/255, blue: 244/255, alpha: 1)
        tf.focusRingType = .none
        tf.delegate = context.coordinator
        return tf
    }

    func updateNSView(_ tf: NSTextField, context: Context) {
        if tf.stringValue != text { tf.stringValue = text }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: FocusableTextField
        init(_ parent: FocusableTextField) { self.parent = parent }

        func controlTextDidChange(_ obj: Notification) {
            guard let tf = obj.object as? NSTextField else { return }
            parent.text = tf.stringValue
        }
        func control(_ control: NSControl, textView: NSTextView, doCommandBy sel: Selector) -> Bool {
            if sel == #selector(NSResponder.insertNewline(_:)) {
                parent.onSubmit()
                return true
            }
            return false
        }
        func controlTextDidBeginEditing(_ obj: Notification) { parent.onFocus(true) }
        func controlTextDidEndEditing(_ obj: Notification) { parent.onFocus(false) }
    }
}

struct HUDView: View {
    let agent: String
    let snippet: String
    let session: String
    let window: String
    let dismissSeconds: Int
    let onDismiss: () -> Void

    @State private var reply = ""
    @State private var progress: Double = 1.0
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var isHovered = false
    @State private var inputFocused = false

    private var showYesNo: Bool { snippet.contains("?") }
    private var autoDismiss: Bool { dismissSeconds > 0 }
    private var paused: Bool { isHovered || inputFocused }

    var body: some View {
        ZStack {
            VisualEffectBlur()
            Color.rpBase.opacity(0.88)
            MouseHoverView { hovered in
                isHovered = hovered
                if hovered { timerTask?.cancel() } else { continueTimer() }
            }

            VStack(spacing: 0) {
                // Top gradient bar
                LinearGradient(colors: [.rpRose, .rpIris], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 3)

                // Header
                HStack {
                    Text(agent)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.rpText)
                    Text("done")
                        .font(.system(size: 12))
                        .foregroundColor(.rpRose)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.rpRose.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.rpRose.opacity(0.3), lineWidth: 1))
                        .cornerRadius(8)
                    Spacer()
                    if autoDismiss && !paused {
                        Text("\(max(0, Int(Double(dismissSeconds) * progress)))s")
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(.rpSubtle)
                    }
                    if paused && autoDismiss {
                        Text("⏸")
                            .font(.system(size: 11))
                            .foregroundColor(.rpSubtle)
                    }
                    Button(action: { dismiss() }) {
                        Text("✕").font(.system(size: 14)).foregroundColor(.rpSubtle)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)

                // Snippet
                if !snippet.isEmpty {
                    HStack(alignment: .top, spacing: 0) {
                        Rectangle().fill(Color.rpRose).frame(width: 3)
                        Text(snippet)
                            .font(.system(size: 14))
                            .foregroundColor(.rpMuted)
                            .lineLimit(8)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 8)
                    }
                    .padding(.horizontal, 14).padding(.bottom, 10)
                }

                // Quick actions
                HStack(spacing: 8) {
                    if showYesNo {
                        actionButton("Yes", fg: .rpRose, bg: Color.rpRose.opacity(0.15), border: Color.rpRose.opacity(0.3)) {
                            TmuxActions.sendReply("yes", window: window); dismiss()
                        }
                        actionButton("No", fg: .rpMuted, bg: Color.rpHighlight.opacity(0.5), border: Color.rpHighlight) {
                            TmuxActions.sendReply("no", window: window); dismiss()
                        }
                    }
                    actionButton("→ Jump", fg: .rpFoam, bg: Color.rpFoam.opacity(0.1), border: Color.rpFoam.opacity(0.2)) {
                        TmuxActions.jumpToWindow(session: session, window: window); dismiss()
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 8)

                // Reply input
                HStack {
                    FocusableTextField(text: $reply, placeholder: "Reply to kiro…", onSubmit: { sendReply() }, onFocus: { focused in
                        inputFocused = focused
                        if focused { timerTask?.cancel() } else { continueTimer() }
                    })
                    .frame(height: 22)
                    Text("↵")
                        .font(.system(size: 11))
                        .foregroundColor(.rpSubtle)
                        .padding(.horizontal, 5).padding(.vertical, 3)
                        .background(Color.rpOverlay)
                        .cornerRadius(4)
                }
                .padding(.horizontal, 10).padding(.vertical, 7)
                .background(Color(hex: "#191724").opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(
                    inputFocused ? Color.rpRose.opacity(0.5) : Color.rpHighlight, lineWidth: 1))
                .cornerRadius(7)
                .padding(.horizontal, 14).padding(.bottom, 12)

                // Countdown bar
                if autoDismiss {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Color.rpOverlay
                            if !paused {
                                LinearGradient(colors: [.rpRose, .rpIris], startPoint: .leading, endPoint: .trailing)
                                    .frame(width: geo.size.width * progress)
                                    .opacity(0.7)
                            } else {
                                Color.rpSubtle.opacity(0.3)
                                    .frame(width: geo.size.width * progress)
                            }
                        }
                    }
                    .frame(height: 3)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rpRose.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.rpRose.opacity(0.1), radius: 32)
        .shadow(color: .black.opacity(0.5), radius: 12, y: 6)
        .onAppear { startTimer() }
    }

    private func actionButton(_ label: String, fg: Color, bg: Color, border: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(fg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(bg)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(border, lineWidth: 1))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func sendReply() {
        guard !reply.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        TmuxActions.sendReply(reply, window: window)
        dismiss()
    }

    private func startTimer() {
        guard autoDismiss else { return }
        timerTask?.cancel()
        timerTask = Task {
            let steps = 100
            let interval = Double(dismissSeconds) / Double(steps)
            for i in stride(from: steps, through: 0, by: -1) {
                guard !Task.isCancelled else { return }
                await MainActor.run { progress = Double(i) / Double(steps) }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
            await MainActor.run { dismiss() }
        }
    }

    // Resume timer from current progress position
    private func continueTimer() {
        guard autoDismiss, progress > 0 else { return }
        timerTask?.cancel()
        timerTask = Task {
            let steps = Int(progress * 100)
            let interval = Double(dismissSeconds) / 100.0
            for i in stride(from: steps, through: 0, by: -1) {
                guard !Task.isCancelled else { return }
                await MainActor.run { progress = Double(i) / 100.0 }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
            await MainActor.run { dismiss() }
        }
    }

    private func dismiss() {
        timerTask?.cancel()
        onDismiss()
    }
}
