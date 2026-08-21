import Foundation
import Testing
@testable import SwordReaderMac

@MainActor
struct AppModelTests {
    @Test func startSelectsFirstInstalledBible() async {
        let service = FakeScriptureService()
        let model = AppModel(service: service)

        await model.start()

        #expect(model.modules.map(\.id) == ["WEB"])
        #expect(model.selectedModuleID == "WEB")
    }

    @Test func firstLaunchPresentsOnboardingUntilCompleted() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let model = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )

        await model.start()
        #expect(model.isPresentingOnboarding)

        model.completeOnboarding()
        #expect(!model.isPresentingOnboarding)

        let restored = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )
        await restored.start()
        #expect(!restored.isPresentingOnboarding)
    }

    @Test func removingSelectedBibleFallsBackToRemainingModule() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let service = FakeScriptureService(modules: [
            BibleModule(id: "WEB", title: "World English Bible", language: "en", version: "1.0", copyright: nil),
            BibleModule(id: "KJV", title: "King James Version", language: "en", version: nil, copyright: "Public domain")
        ])
        let model = AppModel(service: service, defaults: defaults)
        await model.start()

        await model.removeModule(id: "WEB")

        #expect(model.modules.map(\.id) == ["KJV"])
        #expect(model.selectedModuleID == "KJV")
        #expect(await service.removedModuleIDs() == ["WEB"])
    }

    @Test func removingLastBibleLeavesReaderEmpty() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let service = FakeScriptureService()
        let model = AppModel(service: service, defaults: defaults)
        await model.start()

        await model.removeModule(id: "WEB")

        #expect(model.modules.isEmpty)
        #expect(model.selectedModuleID == nil)
        #expect(model.books.isEmpty)
        #expect(model.chapter == nil)
        #expect(model.section == .library)
    }

    @Test func sendingBibleToWatchClearsProgressAfterQueuing() async {
        let companion = FakeCompanionSync()
        let model = AppModel(
            service: FakeScriptureService(),
            companionSync: companion
        )

        await model.sendModuleToWatch("WEB")

        #expect(companion.sentModuleIDs == ["WEB"])
        #expect(model.sendingModuleID == nil)
        #expect(model.presentedError == nil)
    }

    @Test func openingSearchResultLoadsItsChapter() async throws {
        let service = FakeScriptureService()
        let model = AppModel(service: service)
        await model.start()

        model.open(reference: "Romans 8:28")
        try await Task.sleep(for: .milliseconds(20))

        #expect(model.section == .read)
        #expect(model.reference == "Romans 8")
        #expect(model.chapter?.reference == "Romans 8")
    }

    @Test func emptySearchClearsResults() async throws {
        let service = FakeScriptureService()
        let model = AppModel(service: service)
        await model.start()
        model.search("grace")
        try await Task.sleep(for: .milliseconds(20))
        #expect(model.searchResults.count == 1)

        model.search("  ")

        #expect(model.searchResults.isEmpty)
    }

    @Test func restoresSavedModuleBookAndChapter() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        defaults.set("WEB", forKey: "selectedBibleModule")
        defaults.set("Gen", forKey: "readerBook.WEB")
        defaults.set(2, forKey: "readerChapter.WEB")
        let model = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )

        await model.start()
        try await Task.sleep(for: .milliseconds(20))

        #expect(model.selectedModuleID == "WEB")
        #expect(model.selectedBookID == "Gen")
        #expect(model.selectedChapter == 2)
        #expect(model.chapter?.reference == "Genesis 2")
    }

    @Test func chapterNavigationCrossesBookBoundaries() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let model = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )
        await model.start()
        model.select(bookID: "Gen", chapter: 2)

        model.moveChapter(by: 1)
        #expect(model.selectedBookID == "Exod")
        #expect(model.selectedChapter == 1)

        model.moveChapter(by: -1)
        #expect(model.selectedBookID == "Gen")
        #expect(model.selectedChapter == 2)
    }

    @Test func selectionPersistsForAReplacementModel() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let first = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )
        await first.start()
        first.select(bookID: "John", chapter: 3)

        let restored = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )
        await restored.start()

        #expect(restored.selectedBookID == "John")
        #expect(restored.selectedChapter == 3)
    }

    @Test func refreshRemoteCatalogShowsOnlyBibles() async {
        let service = FakeScriptureService()
        let model = AppModel(service: service)

        await model.refreshRemoteCatalog()

        #expect(model.remoteModules.map(\.id) == ["ASV", "WEB"])
        #expect(!model.isRefreshingRemoteCatalog)
    }

    @Test func installingRemoteBibleSelectsItAndReportsCompletion() async {
        let service = FakeScriptureService()
        let model = AppModel(service: service)
        await model.start()
        await model.refreshRemoteCatalog()

        await model.installRemote(model.remoteModules[0])

        #expect(model.selectedModuleID == "ASV")
        #expect(model.installingModuleID == nil)
        #expect(model.installProgress == nil)
        #expect(await service.installedRemoteModuleIDs() == ["ASV"])
    }

    @Test func cancellingRemoteInstallDoesNotPresentAnError() async throws {
        let service = FakeScriptureService(remoteInstallDelay: .seconds(5))
        let model = AppModel(service: service)
        await model.refreshRemoteCatalog()

        let install = Task { await model.installRemote(model.remoteModules[0]) }
        try await Task.sleep(for: .milliseconds(20))
        model.cancelRemoteInstall()
        await install.value

        #expect(model.installingModuleID == nil)
        #expect(model.presentedError == nil)
    }

    @Test func readerAppearancePersistsForAReplacementModel() throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let first = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )

        first.setReaderFont(.serif)
        first.setReaderTextSize(.large)
        first.setReaderSpacing(.relaxed)
        first.setShowsVerseNumbers(false)

        let restored = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )
        #expect(restored.readerFont == .serif)
        #expect(restored.readerTextSize == .large)
        #expect(restored.readerSpacing == .relaxed)
        #expect(!restored.showsVerseNumbers)
    }

    @Test func verseCountsNotesAndCrossReferences() {
        let verse = BibleVerse(
            reference: "John 3:16",
            number: "16",
            text: "For God so loved the world.",
            content: AttributedString("For God so loved the world."),
            headings: [],
            footnotes: [
                BibleFootnote(id: "1", text: "Or, only begotten", type: nil)
            ],
            crossReferences: [
                BibleCrossReference(id: "2", references: ["Romans 5:8", "1 John 4:9"])
            ]
        )

        #expect(verse.annotationCount == 3)
    }

    @Test func searchUsesSelectedOptionsAndStoresBoundedRecents() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let service = FakeScriptureService()
        let model = AppModel(service: service, defaults: defaults)
        await model.start()
        model.setSearchMode(.allWords)
        model.setSearchScope(.newTestament)

        for index in 0..<10 {
            model.search("query \(index)")
            try await Task.sleep(for: .milliseconds(5))
        }
        try await Task.sleep(for: .milliseconds(20))

        #expect(model.recentSearches.count == 8)
        #expect(model.recentSearches.first == "query 9")
        #expect(model.recentSearches.last == "query 2")
        #expect(await service.lastSearchMode() == .allWords)
        #expect(await service.lastSearchScope() == .newTestament)
    }

    @Test func bookmarkPersistsThroughStudyStore() async {
        let store = FakeStudyStore()
        let model = AppModel(
            service: FakeScriptureService(),
            studyStore: store
        )
        await model.start()

        await model.toggleBookmark(reference: "John 3:16")

        #expect(model.isBookmarked(reference: "John 3:16"))
        #expect(store.savedItems().map(\.reference) == ["John 3:16"])
    }

    @Test func noteCanBeUpdatedAndRemoved() async {
        let store = FakeStudyStore()
        let model = AppModel(
            service: FakeScriptureService(),
            studyStore: store
        )
        await model.start()

        await model.saveNote("Remember this", reference: "John 3:16")
        #expect(model.note(reference: "John 3:16") == "Remember this")

        await model.saveNote("", reference: "John 3:16")
        #expect(model.note(reference: "John 3:16") == nil)
    }

    @Test func comparisonPreservesRequestedModuleOrder() async {
        let service = FakeScriptureService(modules: [
            BibleModule(id: "WEB", title: "World English Bible", language: "en", version: nil, copyright: nil),
            BibleModule(id: "KJV", title: "King James Version", language: "en", version: nil, copyright: nil)
        ])
        let model = AppModel(service: service)
        await model.start()

        await model.compare(with: "KJV")

        #expect(model.comparisonModuleID == "KJV")
        #expect(model.parallelVerses.first?.texts.map(\.moduleID) == ["WEB", "KJV"])
    }

    @Test func deepLinkRoundTripsModuleAndReference() throws {
        let destination = ReaderDestination(
            moduleID: "WEB",
            reference: "John 3:16"
        )
        let url = try #require(destination.url)

        #expect(ReaderDestination(url: url) == destination)
    }

    @Test func readingHistoryDeduplicatesMostRecentLocation() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let model = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )
        await model.start()

        model.select(bookID: "John", chapter: 2)
        model.select(bookID: "John", chapter: 3)
        model.select(bookID: "John", chapter: 2)

        #expect(model.readingHistory.map(\.reference) == ["John 2", "John 3"])
    }
}

@MainActor
private final class FakeStudyStore: StudyDataServing {
    private var items: [StudyItem] = []

    func fetchAll() throws -> [StudyItem] { items }

    func toggleBookmark(moduleID: String, reference: String) throws {
        if let index = items.firstIndex(where: {
            $0.kind == .bookmark && $0.moduleID == moduleID && $0.reference == reference
        }) {
            items.remove(at: index)
        } else {
            items.append(
                StudyItem(kind: .bookmark, moduleID: moduleID, reference: reference, text: nil)
            )
        }
    }

    func saveNote(_ text: String?, moduleID: String, reference: String) throws {
        items.removeAll {
            $0.kind == .note && $0.moduleID == moduleID && $0.reference == reference
        }
        if let text, !text.isEmpty {
            items.append(
                StudyItem(kind: .note, moduleID: moduleID, reference: reference, text: text)
            )
        }
    }

    func savedItems() -> [StudyItem] { items }
}

@MainActor
private final class FakeCompanionSync: CompanionSyncing {
    private(set) var sentModuleIDs: [String] = []

    func send(chapter: BibleChapter) {}
    func sendModule(moduleID: String) async throws {
        sentModuleIDs.append(moduleID)
    }
}

private actor FakeScriptureService: ScriptureServing {
    private var availableModules: [BibleModule]
    private var removedIDs: [String] = []
    private var installedRemoteIDs: [String] = []
    private let remoteInstallDelay: Duration
    private var capturedSearchMode: ScriptureSearchMode?
    private var capturedSearchScope: ScriptureSearchScope?

    init(modules: [BibleModule] = [
        BibleModule(
            id: "WEB",
            title: "World English Bible",
            language: "en",
            version: nil,
            copyright: nil
        )
    ], remoteInstallDelay: Duration = .zero) {
        availableModules = modules
        self.remoteInstallDelay = remoteInstallDelay
    }

    func installedBibles() -> [BibleModule] {
        availableModules
    }

    func chapter(_ reference: String, moduleID: String) -> BibleChapter {
        BibleChapter(reference: reference, moduleID: moduleID, verses: [])
    }

    func parallelChapter(
        _ reference: String,
        moduleIDs: [String]
    ) -> [ParallelVerse] {
        [
            ParallelVerse(
                reference: "John 3:16",
                texts: moduleIDs.map {
                    ParallelVerseText(moduleID: $0, text: "Text from \($0)")
                },
                lexicalLinks: []
            )
        ]
    }

    func books(moduleID: String) -> [BibleBook] {
        [
            BibleBook(
                id: "Gen",
                name: "Genesis",
                abbreviation: "Gen",
                chapterCount: 2,
                testament: .old
            ),
            BibleBook(
                id: "Exod",
                name: "Exodus",
                abbreviation: "Exod",
                chapterCount: 2,
                testament: .old
            ),
            BibleBook(
                id: "John",
                name: "John",
                abbreviation: "John",
                chapterCount: 3,
                testament: .new
            ),
            BibleBook(
                id: "Rom",
                name: "Romans",
                abbreviation: "Rom",
                chapterCount: 16,
                testament: .new
            )
        ]
    }

    func search(
        _ query: String,
        moduleID: String,
        mode: ScriptureSearchMode,
        scope: ScriptureSearchScope,
        progress: @escaping @Sendable (Int) -> Void
    ) -> [BibleSearchResult] {
        capturedSearchMode = mode
        capturedSearchScope = scope
        progress(100)
        return [BibleSearchResult(reference: "Ephesians 2:8", moduleID: moduleID, text: query, score: 100)]
    }

    func catalog(at directory: URL) -> LocalCatalog { LocalCatalog(directory: directory, modules: []) }
    func install(moduleID: String, from catalog: LocalCatalog) {}

    func remoteBibles() -> [CatalogModule] {
        [
            CatalogModule(id: "WEB", title: "World English Bible", language: "en", version: nil, copyright: "Public domain", isBible: true),
            CatalogModule(id: "ASV", title: "American Standard Version", language: "en", version: "1.2", copyright: "Public domain", isBible: true)
        ]
    }

    func installRemote(
        moduleID: String,
        progress: @escaping @Sendable (ModuleTransferProgress) -> Void
    ) async throws {
        progress(ModuleTransferProgress(completedBytes: 50, totalBytes: 100))
        if remoteInstallDelay > .zero {
            try await Task.sleep(for: remoteInstallDelay)
        }
        installedRemoteIDs.append(moduleID)
        if !availableModules.contains(where: { $0.id == moduleID }) {
            availableModules.append(
                BibleModule(id: moduleID, title: moduleID, language: "en", version: nil, copyright: nil)
            )
        }
    }

    func remove(moduleID: String) {
        availableModules.removeAll { $0.id == moduleID }
        removedIDs.append(moduleID)
    }

    func removedModuleIDs() -> [String] { removedIDs }
    func installedRemoteModuleIDs() -> [String] { installedRemoteIDs }
    func lastSearchMode() -> ScriptureSearchMode? { capturedSearchMode }
    func lastSearchScope() -> ScriptureSearchScope? { capturedSearchScope }
}
