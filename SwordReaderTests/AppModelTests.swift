import Foundation
import Testing
@testable import SwordReaderMac

@MainActor
struct AppModelTests {
    @Test func catalogFilterIncludesModuleCategoriesAndFiltersLanguage() {
        let modules = [
            CatalogModule(id: "ASV", title: "American Standard Version", language: "en", version: nil, copyright: nil, isBible: true, sourceID: "crosswire"),
            CatalogModule(id: "BAS", title: "Basque New Testament", language: "eu", version: nil, copyright: nil, isBible: true, sourceID: "crosswire"),
            CatalogModule(id: "DEV", title: "A Devotional", language: "en", version: nil, copyright: nil, isBible: false, sourceID: "crosswire"),
            CatalogModule(id: "BAD", title: "Missing Language", language: "", version: nil, copyright: nil, isBible: true, sourceID: "crosswire")
        ]

        #expect(Set(CatalogFilter.availableLanguages(in: modules)) == ["en", "eu"])
        #expect(CatalogFilter.apply(to: modules, query: "", language: nil).map(\.id) == ["ASV", "BAS", "DEV", "BAD"])
        #expect(CatalogFilter.apply(to: modules, query: "", language: "eu").map(\.id) == ["BAS"])
        #expect(CatalogFilter.apply(to: modules, query: "standard", language: nil).map(\.id) == ["ASV"])
    }

    @Test func moduleSourceRejectsInsecureAndMalformedEndpoints() throws {
        #expect(throws: ModuleSourceError.self) {
            try ModuleSource.validated(
                name: "Insecure",
                host: "http://example.com",
                catalogPath: "/sword",
                packagePath: "/sword/zip"
            )
        }
        #expect(throws: ModuleSourceError.self) {
            try ModuleSource.validated(
                name: "Traversal",
                host: "example.com",
                catalogPath: "/sword/../private",
                packagePath: "/sword/zip"
            )
        }
    }

    @Test func approvedModuleSourcesPersistAndCanBeRemoved() throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let source = try ModuleSource.validated(
            name: "Example Bibles",
            host: "modules.example.org",
            catalogPath: "/sword/raw",
            packagePath: "/sword/packages"
        )
        let first = AppModel(service: FakeScriptureService(), defaults: defaults)

        first.approveModuleSource(source)
        #expect(first.moduleSources.contains(source))

        let restored = AppModel(service: FakeScriptureService(), defaults: defaults)
        #expect(restored.moduleSources.contains(source))

        restored.removeModuleSource(source.id)
        #expect(!restored.moduleSources.contains(source))
        #expect(restored.moduleSources.contains(.crossWire))
    }

    @Test func feedbackReportIncludesOnlyReviewedDiagnostics() throws {
        let report = FeedbackReport(
            kind: .bug,
            title: "Chapter does not open",
            details: "The reader remains on the previous chapter.",
            reproductionSteps: "1. Open John 3\n2. Choose chapter 4",
            diagnostics: FeedbackDiagnostics(
                appVersion: "0.1.0 (1)",
                platform: "macOS",
                osVersion: "15.6",
                modules: ["KJV 2.11", "WEB"]
            )
        )

        let body = report.body

        #expect(body.contains("The reader remains on the previous chapter."))
        #expect(body.contains("KJV 2.11, WEB"))
        #expect(!body.localizedCaseInsensitiveContains("bookmark"))
        #expect(!body.localizedCaseInsensitiveContains("search history"))
        #expect(!body.localizedCaseInsensitiveContains("file path"))
    }

    @Test func feedbackReportBuildsEditableGitHubIssueURL() throws {
        let report = FeedbackReport(
            kind: .feature,
            title: "Reading themes",
            details: "Please add more reading themes.",
            reproductionSteps: "",
            diagnostics: FeedbackDiagnostics(
                appVersion: "0.1.0 (1)",
                platform: "iOS",
                osVersion: "19.0",
                modules: []
            )
        )

        let url = try #require(report.githubIssueURL)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

        #expect(components.host == "github.com")
        #expect(components.path == "/orbeavers14/SwordReader/issues/new")
        #expect(query["title"] == "[Feature] Reading themes")
        #expect(query["body"]?.contains("Please add more reading themes.") == true)
    }

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

    @Test func completedOnboardingReturnsOnLaunchWhenNoBibleIsInstalled() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        defaults.set(true, forKey: "completedOnboarding")
        let model = AppModel(
            service: FakeScriptureService(modules: []),
            defaults: defaults
        )

        await model.start()

        #expect(model.modules.isEmpty)
        #expect(model.isPresentingOnboarding)
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
        first.setAppAppearance(.dark)

        let restored = AppModel(
            service: FakeScriptureService(),
            defaults: defaults
        )
        #expect(restored.readerFont == .serif)
        #expect(restored.readerTextSize == .large)
        #expect(restored.readerSpacing == .relaxed)
        #expect(!restored.showsVerseNumbers)
        #expect(restored.appAppearance == .dark)
    }

    @Test func appAppearanceDefaultsToSystem() {
        let suiteName = #function
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let model = AppModel(service: FakeScriptureService(), defaults: defaults)

        #expect(model.appAppearance == .system)
    }

    @Test func builtInChronologicalPlanCoversOneYear() throws {
        let plan = try #require(
            BuiltInReadingPlans.all.first { $0.id == "chronological-365" }
        )

        #expect(plan.days.count == 365)
        #expect(plan.days.flatMap(\.readings).count == 1_189)
        #expect(plan.days.first?.readings.first == "Genesis 1")
        #expect(plan.days.last?.readings.last == "Revelation 22")
    }

    @Test func readingPlanProgressIsOptionalAndPersists() throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let first = AppModel(service: FakeScriptureService(), defaults: defaults)

        #expect(first.readingPlanSelection == nil)
        first.startReadingPlan("new-testament-90")
        first.toggleReadingPlanDay(1)

        let restored = AppModel(service: FakeScriptureService(), defaults: defaults)
        #expect(restored.readingPlanSelection?.planID == "new-testament-90")
        #expect(restored.readingPlanSelection?.completedDayIDs == [1])

        restored.stopReadingPlan()
        #expect(restored.readingPlanSelection == nil)
    }

    @Test func readingPlanReminderRequiresExplicitEnableAndStopsWithPlan() async throws {
        let defaults = try #require(UserDefaults(suiteName: #function))
        defaults.removePersistentDomain(forName: #function)
        let scheduler = FakeReadingPlanReminderScheduler()
        let model = AppModel(
            service: FakeScriptureService(),
            reminderScheduler: scheduler,
            defaults: defaults
        )
        model.startReadingPlan("new-testament-90")

        #expect(scheduler.scheduledTimes.isEmpty)
        let time = try #require(Calendar.current.date(from: DateComponents(hour: 8, minute: 15)))
        await model.setReadingPlanReminder(at: time)

        #expect(scheduler.scheduledTimes == [FakeReadingPlanReminderScheduler.Time(hour: 8, minute: 15)])
        #expect(model.readingPlanReminderTime != nil)

        model.stopReadingPlan()
        #expect(scheduler.disableCount == 1)
        #expect(model.readingPlanReminderTime == nil)
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

    @Test func broadSearchKeepsAVisibleResultLimitAndFullCount() async throws {
        let results = (1...300).map { index in
            BibleSearchResult(
                reference: "Psalm \(index):1",
                moduleID: "WEB",
                text: "Match \(index)",
                score: 300 - index
            )
        }
        let model = AppModel(
            service: FakeScriptureService(searchResults: results)
        )
        await model.start()

        model.search("match")
        try await Task.sleep(for: .milliseconds(20))

        #expect(model.searchResults.count == 250)
        #expect(model.searchResultCount == 300)
        #expect(model.searchResultsWereLimited)

        model.search("")
        #expect(model.searchResultCount == 0)
        #expect(!model.searchResultsWereLimited)
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

    @Test func handoffActivityRoundTripsReadingDestination() throws {
        let expected = ReaderDestination(moduleID: "WEB", reference: "John 3")
        let activity = NSUserActivity(
            activityType: ReaderContinuityActivity.activityType
        )

        ReaderContinuityActivity.update(activity, with: expected)

        #expect(ReaderContinuityActivity.destination(from: activity) == expected)
        #expect(activity.isEligibleForHandoff)
        #expect(!activity.isEligibleForPublicIndexing)
    }

    @Test func handoffFallsBackWhenRequestedBibleIsMissing() async {
        let model = AppModel(service: FakeScriptureService())
        await model.start()

        await model.continueReading(
            from: ReaderDestination(moduleID: "KJV", reference: "John 2")
        )

        #expect(model.selectedModuleID == "WEB")
        #expect(model.reference == "John 2")
        #expect(model.continuityNotice?.destination.moduleID == "KJV")
        #expect(model.continuityNotice?.currentTranslationTitle == "World English Bible")
    }

    @Test func handoffCanDownloadMissingBibleAndContinue() async {
        let model = AppModel(service: FakeScriptureService())
        await model.start()
        await model.continueReading(
            from: ReaderDestination(moduleID: "ASV", reference: "John 2")
        )

        await model.downloadContinuityModule()

        #expect(model.selectedModuleID == "ASV")
        #expect(model.reference == "John 2")
        #expect(model.continuityNotice == nil)
        #expect(model.presentedError == nil)
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

@MainActor
private final class FakeReadingPlanReminderScheduler: ReadingPlanReminderScheduling {
    struct Time: Equatable { let hour: Int; let minute: Int }
    private(set) var scheduledTimes: [Time] = []
    private(set) var disableCount = 0

    func scheduleDaily(hour: Int, minute: Int) async throws {
        scheduledTimes.append(Time(hour: hour, minute: minute))
    }
    func disable() { disableCount += 1 }
}

private actor FakeScriptureService: ScriptureServing {
    private var availableModules: [BibleModule]
    private var removedIDs: [String] = []
    private var installedRemoteIDs: [String] = []
    private let remoteInstallDelay: Duration
    private let providedSearchResults: [BibleSearchResult]?
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
    ], remoteInstallDelay: Duration = .zero,
       searchResults: [BibleSearchResult]? = nil) {
        availableModules = modules
        self.remoteInstallDelay = remoteInstallDelay
        providedSearchResults = searchResults
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
        return providedSearchResults ?? [
            BibleSearchResult(
                reference: "Ephesians 2:8",
                moduleID: moduleID,
                text: query,
                score: 100
            )
        ]
    }

    func catalog(at directory: URL) -> LocalCatalog { LocalCatalog(directory: directory, modules: []) }
    func install(moduleID: String, from catalog: LocalCatalog) {}

    func remoteBibles(from source: ModuleSource) -> [CatalogModule] {
        [
            CatalogModule(id: "WEB", title: "World English Bible", language: "en", version: nil, copyright: "Public domain", isBible: true, sourceID: source.id),
            CatalogModule(id: "ASV", title: "American Standard Version", language: "en", version: "1.2", copyright: "Public domain", isBible: true, sourceID: source.id)
        ]
    }

    func installRemote(
        moduleID: String,
        from source: ModuleSource,
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
