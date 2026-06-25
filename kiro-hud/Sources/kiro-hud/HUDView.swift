import SwiftUI

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
    @FocusState private var inputFocused: Bool

    private var showYesNo: Bool { snippet.contains("?") }
    private var autoDismiss: Bool { dismissSeconds > 0 }

    var body: some View {
        ZStack {
            VisualEffectBlur()
            Color.rpBase.opacity(0.88)

            VStack(spacing: 0) {
                // Top gradient bar
                LinearGradient(colors: [.rpRose, .rpIris], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 2)

                // Header
                HStack {
                    Text(agent)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.rpText)
                    Text("done")
                        .font(.system(size: 9))
                        .foregroundColor(.rpRose)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.rpRose.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.rpRose.opacity(0.3), lineWidth: 1))
                        .cornerRadius(8)
                    Spacer()
                    if autoDismiss && !inputFocused {
                        Text("\(Int(Double(dismissSeconds) * progress))s")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.rpSubtle)
                    }
                    Button(action: { dismiss() }) {
                        Text("✕").font(.system(size: 11)).foregroundColor(.rpSubtle)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)

                // Snippet
                if !snippet.isEmpty {
                    HStack(alignment: .top, spacing: 0) {
                        Rectangle().fill(Color.rpRose).frame(width: 2)
                        Text(snippet)
                            .font(.system(size: 11))
                            .foregroundColor(.rpMuted)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 6)
                    }
                    .padding(.horizontal, 12).padding(.bottom, 8)
                }

                // Quick actions
                HStack(spacing: 6) {
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
                .padding(.horizontal, 12).padding(.bottom, 6)

                // Reply input
                HStack {
                    TextField("Reply to kiro…", text: $reply)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.rpText)
                        .textFieldStyle(.plain)
                        .focused($inputFocused)
                        .onSubmit { sendReply() }
                    Text("↵")
                        .font(.system(size: 9))
                        .foregroundColor(.rpSubtle)
                        .padding(.horizontal, 4).padding(.vertical, 2)
                        .background(Color.rpOverlay)
                        .cornerRadius(3)
                }
                .padding(.horizontal, 8).padding(.vertical, 5)
                .background(Color(hex: "#191724").opacity(0.8))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                    inputFocused ? Color.rpRose.opacity(0.4) : Color.rpHighlight, lineWidth: 1))
                .cornerRadius(6)
                .padding(.horizontal, 12).padding(.bottom, 10)

                // Countdown bar
                if autoDismiss {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Color.rpOverlay
                            LinearGradient(colors: [.rpRose, .rpIris], startPoint: .leading, endPoint: .trailing)
                                .frame(width: geo.size.width * progress)
                                .opacity(0.6)
                        }
                    }
                    .frame(height: 2)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.rpRose.opacity(0.3), lineWidth: 1))
        .shadow(color: Color.rpRose.opacity(0.1), radius: 32)
        .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
        .onAppear { startTimer() }
        .onChange(of: inputFocused) { focused in
            if focused { timerTask?.cancel() } else { startTimer() }
        }
    }

    private func actionButton(_ label: String, fg: Color, bg: Color, border: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(fg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(bg)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(border, lineWidth: 1))
                .cornerRadius(5)
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

    private func dismiss() {
        timerTask?.cancel()
        onDismiss()
    }
}
