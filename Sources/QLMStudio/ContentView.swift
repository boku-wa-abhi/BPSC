import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView()
        } detail: {
            ChatDetailView()
        }
        .navigationSplitViewStyle(.balanced)
        .background(
            Color(.sRGB, red: 0.08, green: 0.1, blue: 0.13, opacity: 1)
                .ignoresSafeArea()
        )
    }
}
