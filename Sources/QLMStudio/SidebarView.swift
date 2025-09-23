import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var appModel: AppModel

    private var selectionBinding: Binding<Chat.ID?> {
        Binding {
            appModel.selectedChatID
        } set: { newValue in
            appModel.selectedChatID = newValue
        }
    }

    var body: some View {
        List(selection: selectionBinding) {
            SectionHeader(title: "Chats")
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            ForEach(appModel.chatGroups) { group in
                Section {
                    ForEach(group.chats) { chat in
                        ChatSidebarRow(chat: chat)
                            .tag(chat.id)
                            .contextMenu {
                                Button("Rename") {}
                                Button("Delete", role: .destructive) {}
                            }
                    }
                    .onDelete { offsets in
                        appModel.deleteChats(at: offsets, in: group)
                    }
                } header: {
                    HStack(spacing: 8) {
                        if let icon = group.iconSystemName {
                            Image(systemName: icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(.sRGB, white: 0.6, opacity: 1))
                        }
                        Text(group.title)
                    }
                    .foregroundStyle(Color(.sRGB, white: 0.6, opacity: 1))
                    .textCase(nil)
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(Color.sidebarBackground)
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.sRGB, white: 0.65, opacity: 1))
            Spacer()
            Button {
                // placeholder for new chat
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(.sRGB, white: 0.5, opacity: 1))
        }
        .padding(.vertical, 4)
    }
}

private struct ChatSidebarRow: View {
    let chat: Chat

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(chat.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(chat.approximateTokenCount) tokens")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(.sRGB, white: 0.45, opacity: 1))
            }
            Spacer()
            Image(systemName: "ellipsis")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(.sRGB, white: 0.35, opacity: 1))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 8))
        .listRowBackground(Color.sidebarRowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private extension Color {
    static let sidebarBackground = Color(.sRGB, red: 0.1, green: 0.12, blue: 0.16, opacity: 1)
    static let sidebarRowBackground = Color(.sRGB, red: 0.14, green: 0.16, blue: 0.2, opacity: 1)
}
