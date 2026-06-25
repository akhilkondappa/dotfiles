import Foundation

struct TabState: Identifiable, Equatable {
    let id = UUID()
    let agent: String
    let snippet: String
    let session: String
    let window: String
    var isRead: Bool = false

    var label: String { "\(session):\(agent)" }
}

struct Notification: Codable {
    let type: String  // "notify" or "stop"
    let agent: String
    let snippet: String
    let session: String
    let window: String
}
