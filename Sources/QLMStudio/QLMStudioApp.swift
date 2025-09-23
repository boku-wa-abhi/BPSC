import SwiftUI

@main
struct QLMStudioApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .frame(minWidth: 1200, minHeight: 700)
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unifiedCompact)
    }
}
