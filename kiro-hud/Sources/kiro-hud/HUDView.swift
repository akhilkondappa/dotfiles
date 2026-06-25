import SwiftUI
import AppKit

private extension Color {
    static let rpBase      = Color(hex: "#1f1d2e")
    static let rpText      = Color(hex: "#e0def4")
    static let rpMuted     = Color(hex: "#908caa")
    static let rpSubtle    = Color(hex: "#6e6a86")
    static let rpRose      = Color(hex: "#eb6f92")
    static let rpIris      = Color(hex: "#c4a7e7")
    static let rpFoam      = Color(hex: "#9ccfd8")
    static let rpHighlight = Color(hex: "#403d52")
    static let rpOverlay   = Color(hex: "#2a2837")
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0; Scanner(string: h).scanHexInt64(&rgb)
        self.init(red: Double((rgb >> 16) & 0xff) / 255, green: Double((rgb >> 8) & 0xff) / 255, blue: Double(rgb & 0xff) / 255)
    }
}

struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView(); v.state = .active; v.material = .hudWindow
        v.blendingMode = .behindWindow; v.appearance = NSAppearance(named: .darkAqua); return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) {}
}

struct FocusableTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onSubmit: () -> Void

    func makeNSView(context: Context) -> NSTextField {
        let tf = NSTextField()
        tf.placeholderString = placeholder; tf.isBordered = false; tf.drawsBackground = false
        tf.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        tf.textColor = NSColor(red: 224/255, green: 222/255, blue: 244/255, alpha: 1)
        tf.focusRingType = .none; tf.delegate = context.coordinator; return tf
    }
    func updateNSView(_ tf: NSTextField, context: Context) { if tf.stringValue != text { tf.stringValue = text } }
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: FocusableTextField
        init(_ parent: FocusableTextField) { self.parent = parent }
        func controlTextDidChange(_ obj: Foundation.Notification) {
            guard let tf = obj.object as? NSTextField else { return }; parent.text = tf.stringValue
        }
        func control(_ control: NSControl, textView: NSTextView, doCommandBy sel: Selector) -> Bool {
            if sel == #selector(NSResponder.insertNewline(_:)) { parent.onSubmit(); return true }; return false
        }
    }
}

struct HUDView: View {
    @ObservedObject var controller: HUDWindowController
    @State private var reply = ""

    private var activeTab: TabState? { controller.tabs.first { $0.id == controller.activeTabId } }
    private var showYesNo: Bool { activeTab?.snippet.contains("?") ?? false }

    var body: some View {
        ZStack {
            VisualEffectBlur()
            Color.rpBase.opacity(0.88)

            VStack(spacing: 0) {
                // Gradient bar
                LinearGradient(colors: [.rpRose, .rpIris], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 3)

                // Header with tabs
                HStack(alignment: .center) {
                    // Tab bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(controller.tabs) { tab in
                                tabPill(tab)
                            }
                        }
                    }
                    Spacer()
                    Button(action: { controller.toggleExpand() }) {
                        Text(controller.isExpanded ? "↙" : "↗").font(.system(size: 14)).foregroundColor(.rpIris)
                    }.buttonStyle(.plain)
                    Button(action: { controller.removeAllTabs() }) {
                        Text("✕").font(.system(size: 14)).foregroundColor(.rpSubtle)
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)

                // Content for active tab
                if let tab = activeTab {
                    // Snippet
                    ScrollView(.vertical, showsIndicators: true) {
                        HStack(alignment: .top, spacing: 0) {
                            Rectangle().fill(Color.rpRose).frame(width: 3)
                            Text(tab.snippet)
                                .font(.system(size: 14))
                                .foregroundColor(.rpMuted)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .padding(.horizontal, 12)
                    }
                    .frame(maxHeight: controller.isExpanded ? .infinity : 80)
                    .padding(.bottom, 8)

                    Spacer(minLength: 0)

                    // Actions
                    HStack(spacing: 8) {
                        if showYesNo {
                            actionBtn("Yes", fg: .rpRose, bg: Color.rpRose.opacity(0.15), border: Color.rpRose.opacity(0.3)) {
                                TmuxActions.sendReply("yes", window: tab.window)
                                controller.removeTab(tab.id)
                            }
                            actionBtn("No", fg: .rpMuted, bg: Color.rpHighlight.opacity(0.5), border: Color.rpHighlight) {
                                TmuxActions.sendReply("no", window: tab.window)
                                controller.removeTab(tab.id)
                            }
                        }
                        actionBtn("→ Jump", fg: .rpFoam, bg: Color.rpFoam.opacity(0.1), border: Color.rpFoam.opacity(0.2)) {
                            TmuxActions.jumpToWindow(session: tab.session, window: tab.window)
                            controller.removeTab(tab.id)
                        }
                    }
                    .padding(.horizontal, 12).padding(.bottom, 6)

                    // Reply
                    HStack {
                        FocusableTextField(text: $reply, placeholder: "Reply to kiro…", onSubmit: { sendReply(tab) })
                            .frame(height: 22)
                        Text("↵").font(.system(size: 11)).foregroundColor(.rpSubtle)
                            .padding(.horizontal, 5).padding(.vertical, 3)
                            .background(Color.rpOverlay).cornerRadius(4)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color(hex: "#191724").opacity(0.8))
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.rpHighlight, lineWidth: 1))
                    .cornerRadius(7)
                    .padding(.horizontal, 12).padding(.bottom, 10)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: controller.isExpanded ? 10 : 14))
        .overlay(RoundedRectangle(cornerRadius: controller.isExpanded ? 10 : 14).stroke(Color.rpRose.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.rpRose.opacity(0.1), radius: 32)
        .shadow(color: .black.opacity(0.5), radius: 12, y: 6)
    }

    private func tabPill(_ tab: TabState) -> some View {
        let isActive = tab.id == controller.activeTabId
        let isUnread = !tab.isRead && !isActive

        return Button(action: { controller.selectTab(tab.id) }) {
            HStack(spacing: 4) {
                Text(tab.label).font(.system(size: 11, weight: isUnread ? .semibold : .regular))
                    .foregroundColor(isActive ? .rpText : isUnread ? .rpIris : .rpSubtle)
                    .lineLimit(1)
                // Per-tab close
                Button(action: { controller.removeTab(tab.id) }) {
                    Text("✕").font(.system(size: 9)).foregroundColor(.rpSubtle)
                }.buttonStyle(.plain)
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(isActive ? Color.rpRose.opacity(0.15) : Color.rpHighlight.opacity(0.3))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                isActive ? Color.rpRose.opacity(0.3) :
                isUnread ? Color.rpIris.opacity(0.6) : Color.clear, lineWidth: 1))
            .shadow(color: isUnread ? Color.rpIris.opacity(0.3) : .clear, radius: 4)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func actionBtn(_ label: String, fg: Color, bg: Color, border: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(fg).frame(maxWidth: .infinity).padding(.vertical, 7)
                .background(bg).overlay(RoundedRectangle(cornerRadius: 6).stroke(border, lineWidth: 1)).cornerRadius(6)
        }.buttonStyle(.plain)
    }

    private func sendReply(_ tab: TabState) {
        let text = reply.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        TmuxActions.sendReply(text, window: tab.window)
        reply = ""
        controller.removeTab(tab.id)
    }
}
