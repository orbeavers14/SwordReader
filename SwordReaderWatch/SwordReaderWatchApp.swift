import SwiftUI

@main
struct SwordReaderWatchApp: App {
    @State private var model = WatchReaderModel()

    var body: some Scene {
        WindowGroup {
            WatchReaderView()
                .environment(model)
        }
    }
}
