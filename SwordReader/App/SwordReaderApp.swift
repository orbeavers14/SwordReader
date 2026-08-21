import SwiftUI

@main
struct SwordReaderApp: App {
    var body: some Scene {
        WindowGroup {
            SwordReaderSceneView()
        }
        WindowGroup("Passage", for: ReaderDestination.self) { destination in
            SwordReaderSceneView(initialDestination: destination.wrappedValue)
        }
        #if os(macOS)
        .commands { SwordReaderCommands() }
        #endif
    }
}

private struct SwordReaderSceneView: View {
    @State private var model = AppModel()
    @SceneStorage("reader.sceneDestination") private var storedDestination = ""
    let initialDestination: ReaderDestination?

    init(initialDestination: ReaderDestination? = nil) {
        self.initialDestination = initialDestination
    }

    var body: some View {
        RootView()
            .environment(model)
            #if os(macOS)
            .focusedSceneValue(\.swordReaderModel, model)
            #endif
            .task {
                await model.start()
                if let initialDestination {
                    await model.open(destination: initialDestination)
                } else if let url = URL(string: storedDestination),
                          let restored = ReaderDestination(url: url) {
                    await model.open(destination: restored)
                }
            }
            .onOpenURL { url in
                Task { await model.open(url: url) }
            }
            .onChange(of: model.currentDestination) { _, destination in
                storedDestination = destination?.url?.absoluteString ?? ""
            }
    }
}
