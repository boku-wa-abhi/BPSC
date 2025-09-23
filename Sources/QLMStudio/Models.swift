import Foundation
import SwiftUI

struct ChatGroup: Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String
    let iconSystemName: String?
    var chats: [Chat]

    init(title: String, iconSystemName: String?, chats: [Chat]) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.chats = chats
    }
}

struct Chat: Identifiable, Hashable {
    typealias ID = UUID

    let id: UUID
    var title: String
    var messages: [Message]
    var updatedAt: Date

    init(id: UUID = UUID(), title: String, messages: [Message]) {
        self.id = id
        self.title = title
        self.messages = messages
        self.updatedAt = messages.last?.timestamp ?? Date()
    }

    var approximateTokenCount: Int {
        messages.reduce(0) { partialResult, message in
            partialResult + message.tokenEstimate
        }
    }
}

struct Message: Identifiable, Hashable {
    let id: UUID = UUID()
    let role: MessageRole
    var content: String
    var timestamp: Date

    var tokenEstimate: Int {
        max(12, content.split(separator: " ").count * 3)
    }
}

enum MessageRole: String, Hashable {
    case system
    case user
    case assistant

    var bubbleAlignment: HorizontalAlignment {
        switch self {
        case .system:
            return .center
        case .user:
            return .trailing
        case .assistant:
            return .leading
        }
    }

    var bubbleBackground: Color {
        switch self {
        case .system:
            return Color(.sRGB, red: 0.15, green: 0.19, blue: 0.24, opacity: 1)
        case .user:
            return Color(.sRGB, red: 0.26, green: 0.32, blue: 0.48, opacity: 1)
        case .assistant:
            return Color(.sRGB, red: 0.16, green: 0.2, blue: 0.27, opacity: 1)
        }
    }

    var textColor: Color {
        switch self {
        case .user:
            return .white
        case .assistant, .system:
            return Color(.sRGB, white: 0.85, opacity: 1)
        }
    }
}
