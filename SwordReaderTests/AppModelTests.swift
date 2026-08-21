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
}

private actor FakeScriptureService: ScriptureServing {
    private var availableModules: [BibleModule]
    private var removedIDs: [String] = []
    private var installedRemoteIDs: [String] = []
    private let remoteInstallDelay: Duration

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

    func search(_ query: String, moduleID: String) -> [BibleSearchResult] {
        [BibleSearchResult(reference: "Ephesians 2:8", moduleID: moduleID, text: query, score: 100)]
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
}
