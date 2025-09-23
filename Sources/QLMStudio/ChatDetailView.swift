import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        ZStack {
            Color.chatBackground.ignoresSafeArea()

            if let chat = appModel.selectedChat {
                VStack(spacing: 0) {
                    ModelControlBar(
                        modelManager: appModel.modelManager,
                        isGenerating: appModel.isGeneratingResponse
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 12)

                    Divider().overlay(Color.divider)

                    MessagesScrollView(chat: chat, scrollProxy: $scrollProxy)

                    Divider().overlay(Color.divider)

                    MessageComposer()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                }
            } else {
                PlaceholderView()
            }
        }
        .onChange(of: appModel.selectedChat?.messages.count ?? 0) { _ in
            scrollToBottom()
        }
    }

    private func scrollToBottom() {
        guard let lastMessageID = appModel.selectedChat?.messages.last?.id else { return }
        scrollProxy?.scrollTo(lastMessageID, anchor: .bottom)
    }
}

private struct ModelControlBar: View {
    @ObservedObject var modelManager: ModelManager
    var isGenerating: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(modelManager.readableModelName())
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.sRGB, red: 0.15, green: 0.19, blue: 0.25, opacity: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(Color(.sRGB, white: 0.85, opacity: 1))

                Button("Eject") {
                    // Placeholder action
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.sRGB, red: 0.24, green: 0.1, blue: 0.1, opacity: 1))
                .foregroundStyle(Color(.sRGB, red: 0.9, green: 0.3, blue: 0.32, opacity: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .buttonStyle(.plain)

                Spacer()

                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            Text(modelManager.metadataSummary())
                .font(.system(size: 12))
                .foregroundStyle(Color(.sRGB, white: 0.55, opacity: 1))
        }
        .task {
            await modelManager.loadModelMetadata()
        }
    }
}

private struct MessagesScrollView: View {
    let chat: Chat
    @Binding var scrollProxy: ScrollViewProxy?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if chat.messages.isEmpty {
                        PlaceholderView()
                    } else {
                        ForEach(chat.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 16)
            }
            .onAppear {
                scrollProxy = proxy
            }
        }
    }
}

private struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 38, weight: .light))
                .foregroundStyle(Color(.sRGB, red: 0.45, green: 0.32, blue: 0.9, opacity: 1))
            Text("QLM STUDIO")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(.sRGB, white: 0.5, opacity: 1))
            Text("Select a chat or start typing to talk to the model.")
                .font(.system(size: 14))
                .foregroundStyle(Color(.sRGB, white: 0.45, opacity: 1))
        }
    }
}

private struct MessageComposer: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    // Attachment placeholder
                } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(.sRGB, white: 0.55, opacity: 1))

                ZStack(alignment: .topLeading) {
                    if appModel.composerText.isEmpty {
                        Text("Send a message to the model…")
                            .foregroundStyle(Color(.sRGB, white: 0.4, opacity: 1))
                            .padding(.top, 8)
                            .padding(.leading, 6)
                    }

                    TextEditor(text: $appModel.composerText)
                        .frame(minHeight: 32, maxHeight: 140)
                        .scrollContentBackground(.hidden)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.sRGB, white: 0.85, opacity: 1))
                        .padding(6)
                        .background(Color(.sRGB, red: 0.13, green: 0.16, blue: 0.22, opacity: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    appModel.sendCurrentMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(.sRGB, red: 0.52, green: 0.78, blue: 0.99, opacity: 1))
                }
                .buttonStyle(.plain)
                .disabled(appModel.composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appModel.isGeneratingResponse)
            }

            if let status = appModel.statusMessage {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text(status)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.sRGB, white: 0.55, opacity: 1))
                }
            }
        }
        .padding(18)
        .background(Color(.sRGB, red: 0.1, green: 0.12, blue: 0.17, opacity: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 40)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(message.role == .user ? "You" : "QLM Model")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(.sRGB, white: 0.5, opacity: 1))

                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundStyle(message.role.textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(message.role.bubbleBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if message.role == .assistant {
                Spacer(minLength: 40)
            }
        }
    }
}

private extension Color {
    static let chatBackground = Color(.sRGB, red: 0.09, green: 0.11, blue: 0.15, opacity: 1)
    static let divider = Color(.sRGB, white: 0.2, opacity: 1)
}
