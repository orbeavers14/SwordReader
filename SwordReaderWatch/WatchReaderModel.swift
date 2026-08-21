import Foundation
import Observation
import SwordKit
import WatchConnectivity

struct WatchBible: Identifiable, Hashable, Sendable { let id: String; let title: String }
struct WatchBook: Identifiable, Hashable, Sendable { let id: String; let name: String; let chapterCount: Int }
struct WatchVerse: Identifiable, Hashable, Sendable { let id: String; let number: String; let text: String }
struct WatchCatalogBible: Identifiable, Hashable, Sendable { let id: String; let title: String; let language: String }

@MainActor @Observable
final class WatchReaderModel: NSObject, WCSessionDelegate {
    private(set) var modules: [WatchBible] = []
    private(set) var books: [WatchBook] = []
    private(set) var verses: [WatchVerse] = []
    private(set) var remoteModules: [WatchCatalogBible] = []
    private(set) var selectedModuleID: String?
    private(set) var selectedBookID: String?
    private(set) var selectedChapter = 1
    private(set) var isLoading = false
    private(set) var isInstalling = false
    private(set) var isLoadingChapter = false
    private(set) var installingModuleID: String?
    var presentedError: String?

    private let library: SwordLibrary
    private let installer: SwordModuleInstaller
    private let repository: SwordModuleRepository
    private static let moduleKey = "watch.module"
    private static let bookKey = "watch.book"
    private static let chapterKey = "watch.chapter"
    private var chapterTask: Task<Void, Never>?
    private var chapterGeneration = UUID()

    override init() {
        do {
            let location = try SwordModuleLocation.applicationSupport()
            let repository = try Self.crossWireRepository()
            library = try SwordLibrary(location: location)
            installer = SwordModuleInstaller(configuration: .init(location: location, repositories: [repository]))
            self.repository = repository
        } catch { fatalError("Unable to prepare SwordReader storage: \(error)") }
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    var reference: String {
        guard let book = books.first(where: { $0.id == selectedBookID }) else { return "" }
        return "\(book.name) \(selectedChapter)"
    }
    var canMoveBackward: Bool {
        guard let id = selectedBookID, let index = books.firstIndex(where: { $0.id == id }) else { return false }
        return selectedChapter > 1 || index > books.startIndex
    }
    var canMoveForward: Bool {
        guard let book = books.first(where: { $0.id == selectedBookID }), let index = books.firstIndex(of: book) else { return false }
        return selectedChapter < book.chapterCount || index < books.index(before: books.endIndex)
    }

    func start() { refreshLibrary() }
    func selectModule(_ id: String) { guard id != selectedModuleID else { return }; activateModule(id, restoring: false) }
    func selectBook(_ id: String) {
        guard books.contains(where: { $0.id == id }) else { return }
        selectedBookID = id; selectedChapter = 1; persistSelection(); loadChapter()
    }
    func selectChapter(_ chapter: Int) {
        guard let book = books.first(where: { $0.id == selectedBookID }), (1...book.chapterCount).contains(chapter) else { return }
        selectedChapter = chapter; persistSelection(); loadChapter()
    }
    func moveChapter(by offset: Int) {
        guard abs(offset) == 1, let book = books.first(where: { $0.id == selectedBookID }), let index = books.firstIndex(of: book) else { return }
        if offset < 0, selectedChapter > 1 { selectChapter(selectedChapter - 1) }
        else if offset < 0, index > books.startIndex {
            let previous = books[books.index(before: index)]; selectedBookID = previous.id; selectedChapter = previous.chapterCount; persistSelection(); loadChapter()
        } else if offset > 0, selectedChapter < book.chapterCount { selectChapter(selectedChapter + 1) }
        else if offset > 0, index < books.index(before: books.endIndex) {
            selectedBookID = books[books.index(after: index)].id; selectedChapter = 1; persistSelection(); loadChapter()
        }
    }

    func refreshRemoteCatalog() async {
        isLoading = true; defer { isLoading = false }
        do {
            let catalog = try await installer.refreshCatalog(for: repository, acknowledgingRemoteAccessRisks: true)
            remoteModules = catalog.modules.filter { $0.category == .bible }.map {
                WatchCatalogBible(id: $0.name, title: $0.title.isEmpty ? $0.name : $0.title, language: $0.language)
            }.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        } catch { presentedError = error.localizedDescription }
    }
    func installRemote(_ module: WatchCatalogBible) async {
        guard !isInstalling else { return }
        isInstalling = true; installingModuleID = module.id
        defer { isInstalling = false; installingModuleID = nil }
        do {
            try await installer.install(moduleNamed: module.id, from: repository, acknowledgingRemoteAccessRisks: true)
            refreshLibrary(preferredModuleID: module.id)
        } catch { presentedError = error.localizedDescription }
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}
    nonisolated func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let moduleID = file.metadata?["moduleID"] as? String else { return }
        do {
            let received = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).zip")
            try FileManager.default.copyItem(at: file.fileURL, to: received)
            Task { @MainActor in self.installReceived(moduleID: moduleID, archive: received) }
        } catch {
            let message = error.localizedDescription
            Task { @MainActor in self.presentedError = message }
        }
    }

    private func installReceived(moduleID: String, archive: URL) {
        defer { try? FileManager.default.removeItem(at: archive) }
        do { try installer.install(moduleNamed: moduleID, fromArchive: archive); refreshLibrary(preferredModuleID: moduleID) }
        catch { presentedError = error.localizedDescription }
    }
    private func refreshLibrary(preferredModuleID: String? = nil) {
        library.refresh()
        modules = library.modules(category: .bible).map { WatchBible(id: $0.name, title: $0.title.isEmpty ? $0.name : $0.title) }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        guard !modules.isEmpty else { selectedModuleID = nil; books = []; verses = []; return }
        let requested = preferredModuleID ?? UserDefaults.standard.string(forKey: Self.moduleKey)
        let id = modules.first(where: { $0.id == requested })?.id ?? modules[0].id
        activateModule(id, restoring: preferredModuleID == nil)
    }
    private func activateModule(_ id: String, restoring: Bool) {
        guard let module = library.module(named: id) else { return }
        do {
            books = try module.books().map { WatchBook(id: $0.osisName, name: $0.name, chapterCount: $0.chapterCount) }
            selectedModuleID = id
            let saved = restoring ? UserDefaults.standard.string(forKey: Self.bookKey) : nil
            let book = books.first(where: { $0.id == saved }) ?? books.first(where: { $0.id == "John" }) ?? books.first
            selectedBookID = book?.id
            let savedChapter = restoring ? UserDefaults.standard.integer(forKey: Self.chapterKey) : 0
            selectedChapter = min(max(savedChapter, 1), book?.chapterCount ?? 1)
            persistSelection(); loadChapter()
        } catch { presentedError = error.localizedDescription }
    }
    private func loadChapter() {
        chapterTask?.cancel()
        guard let moduleID = selectedModuleID,
              let module = library.module(named: moduleID),
              !reference.isEmpty
        else { return }

        let requestedReference = reference
        let generation = UUID()
        chapterGeneration = generation
        isLoadingChapter = true
        chapterTask = Task {
            do {
                let loaded = try await Task.detached(priority: .userInitiated) {
                    try Task.checkCancellation()
                    let chapter = try module.chapter(requestedReference)
                    try Task.checkCancellation()
                    return chapter.verses.map {
                        WatchVerse(
                            id: $0.reference.value,
                            number: $0.reference.value.split(separator: ":")
                                .last.map(String.init) ?? "",
                            text: $0.text
                        )
                    }
                }.value
                guard !Task.isCancelled,
                      chapterGeneration == generation
                else { return }
                verses = loaded
            } catch is CancellationError {
                // A newer chapter owns the visible state.
            } catch {
                guard chapterGeneration == generation else { return }
                presentedError = error.localizedDescription
            }
            guard chapterGeneration == generation else { return }
            isLoadingChapter = false
        }
    }
    private func persistSelection() {
        UserDefaults.standard.set(selectedModuleID, forKey: Self.moduleKey)
        UserDefaults.standard.set(selectedBookID, forKey: Self.bookKey)
        UserDefaults.standard.set(selectedChapter, forKey: Self.chapterKey)
    }
    private static func crossWireRepository() throws -> SwordModuleRepository {
        try .init(identifier: "crosswire", name: "CrossWire Bible Society", transport: .https, host: "www.crosswire.org", directory: "/ftpmirror/pub/sword/raw", packageDirectory: "/ftpmirror/pub/sword/packages/rawzip")
    }
}
