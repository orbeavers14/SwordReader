import SwiftUI

struct WatchReaderView: View {
    @Environment(WatchReaderModel.self) private var model
    @State private var isShowingRemoteWarning = false
    @State private var isShowingCatalog = false

    var body: some View {
        NavigationStack {
            Group {
                if model.modules.isEmpty {
                    ContentUnavailableView {
                        Label("No Bible", systemImage: "book.closed")
                    } description: {
                        Text("Send a Bible from iPhone or download one directly.")
                    } actions: {
                        Button("Get Bibles") { isShowingRemoteWarning = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(model.verses) { verse in
                            Text(verse.number + " ")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            + Text(verse.text)
                        }
                    }
                    .navigationTitle(model.reference)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Previous", systemImage: "chevron.left") { model.moveChapter(by: -1) }
                                .labelStyle(.iconOnly)
                                .disabled(!model.canMoveBackward)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Next", systemImage: "chevron.right") { model.moveChapter(by: 1) }
                                .labelStyle(.iconOnly)
                                .disabled(!model.canMoveForward)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink {
                        WatchNavigationView()
                    } label: {
                        Label("Choose Passage", systemImage: "list.bullet")
                    }
                    .disabled(model.modules.isEmpty)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Get Bibles", systemImage: "arrow.down.circle") { isShowingRemoteWarning = true }
                }
            }
        }
        .task { model.start() }
        .confirmationDialog("Connect to CrossWire?", isPresented: $isShowingRemoteWarning, titleVisibility: .visible) {
            Button("Continue") { isShowingCatalog = true; Task { await model.refreshRemoteCatalog() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("SwordReader will contact the CrossWire Bible Society. This may reveal that you use a Bible reader. Modules have separate licenses.")
        }
        .sheet(isPresented: $isShowingCatalog) { WatchCatalogView() }
        .alert("SwordReader", isPresented: Binding(get: { model.presentedError != nil }, set: { if !$0 { model.presentedError = nil } })) {
            Button("OK") { model.presentedError = nil }
        } message: { Text(model.presentedError ?? "") }
    }
}

private struct WatchNavigationView: View {
    @Environment(WatchReaderModel.self) private var model

    var body: some View {
        List {
            if model.modules.count > 1 {
                NavigationLink("Bible") {
                    List(model.modules) { module in
                        Button(module.title) { model.selectModule(module.id) }
                    }.navigationTitle("Bible")
                }
            }
            NavigationLink("Book") {
                List(model.books) { book in
                    Button(book.name) { model.selectBook(book.id) }
                }.navigationTitle("Book")
            }
            NavigationLink("Chapter") {
                if let book = model.books.first(where: { $0.id == model.selectedBookID }) {
                    List(1...book.chapterCount, id: \.self) { chapter in
                        Button("Chapter \(chapter)") { model.selectChapter(chapter) }
                    }.navigationTitle("Chapter")
                }
            }
        }
        .navigationTitle("Choose Passage")
    }
}

private struct WatchCatalogView: View {
    @Environment(WatchReaderModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if model.isLoading && model.remoteModules.isEmpty { ProgressView("Finding Bibles…") }
                else {
                    List(model.remoteModules) { module in
                        Button {
                            Task { await model.installRemote(module); if model.selectedModuleID == module.id { dismiss() } }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(module.title)
                                Text("\(module.id) · \(module.language)").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .disabled(model.isInstalling)
                    }
                }
            }
            .navigationTitle("Get Bibles")
            .toolbar { Button("Done") { dismiss() } }
            .overlay { if model.isInstalling { ProgressView("Installing…") } }
        }
    }
}
