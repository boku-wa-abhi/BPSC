import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var chatGroups: [ChatGroup]
    @Published var selectedChatID: Chat.ID?
    @Published var composerText: String = ""
    @Published var isGeneratingResponse = false
    @Published var statusMessage: String? = nil

    let modelManager: ModelManager

    init(modelManager: ModelManager = ModelManager()) {
        self.modelManager = modelManager
        self.chatGroups = AppModel.makeSampleChats()
        self.selectedChatID = chatGroups.first?.chats.first?.id

        Task {
            await modelManager.loadModelMetadata()
        }
    }

    var selectedChat: Chat? {
        guard let chatID = selectedChatID else { return nil }
        return chat(for: chatID)
    }

    func selectChat(_ chat: Chat) {
        selectedChatID = chat.id
    }

    func sendCurrentMessage() {
        let trimmed = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let chatID = selectedChatID else { return }

        composerText = ""
        let message = Message(role: .user, content: trimmed, timestamp: Date())
        append(message: message, to: chatID)

        isGeneratingResponse = true
        statusMessage = "Generating response..."

        Task {
            let replyText = await modelManager.generateResponse(for: trimmed)
            await MainActor.run {
                let reply = Message(role: .assistant, content: replyText, timestamp: Date())
                self.append(message: reply, to: chatID)
                self.isGeneratingResponse = false
                self.statusMessage = nil
            }
        }
    }

    func regenerateResponse() {
        guard let chat = selectedChat, let lastUserMessage = chat.messages.last(where: { $0.role == .user }) else {
            return
        }
        composerText = lastUserMessage.content
        sendCurrentMessage()
    }

    func deleteChats(at offsets: IndexSet, in group: ChatGroup) {
        guard let groupIndex = chatGroups.firstIndex(where: { $0.id == group.id }) else { return }
        chatGroups[groupIndex].chats.remove(atOffsets: offsets)
        if let firstChat = chatGroups[groupIndex].chats.first {
            selectedChatID = firstChat.id
        } else {
            selectedChatID = chatGroups.first(where: { !$0.chats.isEmpty })?.chats.first?.id
        }
    }

    private func append(message: Message, to chatID: Chat.ID) {
        guard let path = indexPath(for: chatID) else { return }
        chatGroups[path.groupIndex].chats[path.chatIndex].messages.append(message)
        chatGroups[path.groupIndex].chats[path.chatIndex].updatedAt = message.timestamp
    }

    private func chat(for chatID: Chat.ID) -> Chat? {
        guard let path = indexPath(for: chatID) else { return nil }
        return chatGroups[path.groupIndex].chats[path.chatIndex]
    }

    private func indexPath(for chatID: Chat.ID) -> (groupIndex: Int, chatIndex: Int)? {
        for (groupIndex, group) in chatGroups.enumerated() {
            if let chatIndex = group.chats.firstIndex(where: { $0.id == chatID }) {
                return (groupIndex, chatIndex)
            }
        }
        return nil
    }

    private static func makeSampleChats() -> [ChatGroup] {
        let placeholderMessages: [Message] = [
            Message(role: .assistant, content: "Welcome to QLM Studio! Select a chat or start a new one to begin.", timestamp: Date())
        ]

        let smbcChats = [
            Chat(title: "Unnamed Chat", messages: placeholderMessages),
            Chat(title: "Quantum Computer Types", messages: []),
            Chat(title: "Quantum Computing Explained", messages: []),
            Chat(title: "Campaign Planning & Analysis", messages: []),
            Chat(title: "Client Names and Description", messages: []),
            Chat(title: "Columns Name and Description", messages: [])
        ]

        let qlmChats = [
            Chat(title: "Unnamed Chat", messages: placeholderMessages)
        ]

        return [
            ChatGroup(title: "Project SMBC", iconSystemName: "folder.fill", chats: smbcChats),
            ChatGroup(title: "Project QLM", iconSystemName: "folder", chats: qlmChats)
        ]
    }
}
