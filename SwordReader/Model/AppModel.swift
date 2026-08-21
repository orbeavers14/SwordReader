import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var section: AppSection = .read
    private(set) var readerFont: ReaderFont
    private(set) var readerTextSize: ReaderTextSize
    private(set) var readerSpacing: ReaderSpacing
    private(set) var showsVerseNumbers: Bool
    private(set) var modules: [BibleModule] = []
    private(set) var selectedModuleID: String?
    private(set) var books: [BibleBook] = []
    private(set) var selectedBookID: String?
    private(set) var selectedChapter = 1
    private(set) var chapter: BibleChapter?
    private(set) var parallelVerses: [ParallelVerse] = []
    private(set) var comparisonModuleID: String?
    private(set) var isLoadingComparison = false
    private(set) var searchResults: [BibleSearchResult] = []
    private(set) var searchMode: ScriptureSearchMode
    private(set) var searchScope: ScriptureSearchScope
    private(set) var searchProgress: Int?
    private(set) var recentSearches: [String]
    private(set) var studyItems: [StudyItem] = []
    private(set) var readingHistory: [ReadingHistoryEntry]
    private(set) var catalog: LocalCatalog?
    private(set) var remoteModules: [CatalogModule] = []
    private(set) var isLoading = false
    private(set) var isSearching = false
    private(set) var isInstalling = false
    private(set) var isRefreshingRemoteCatalog = false
    private(set) var installingModuleID: String?
    private(set) var installProgress: ModuleTransferProgress?
    private(set) var removingModuleID: String?
    private(set) var isPresentingOnboarding = false
    var presentedError: PresentedError?

    private let service: any ScriptureServing
    private let defaults: UserDefaults
    private let studyStore: (any StudyDataServing)?
    private var chapterTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var searchGeneration = UUID()
    private var remoteInstallTask: Task<Void, Error>?
    private var comparisonTask: Task<Void, Never>?
    private static let moduleKey = "selectedBibleModule"
    private static let bookKeyPrefix = "readerBook."
    private static let chapterKeyPrefix = "readerChapter."
    private static let completedOnboardingKey = "completedOnboarding"
    private static let readerFontKey = "reader.font"
    private static let readerTextSizeKey = "reader.textSize"
    private static let readerSpacingKey = "reader.spacing"
    private static let showsVerseNumbersKey = "reader.showsVerseNumbers"
    private static let searchModeKey = "search.mode"
    private static let searchScopeKey = "search.scope"
    private static let recentSearchesKey = "search.recents"
    private static let readingHistoryKey = "reader.history"

    init(
        service: any ScriptureServing,
        studyStore: (any StudyDataServing)? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.service = service
        self.studyStore = studyStore
        self.defaults = defaults
        readerFont = ReaderFont(
            rawValue: defaults.string(forKey: Self.readerFontKey) ?? ""
        ) ?? .system
        readerTextSize = ReaderTextSize(
            rawValue: defaults.string(forKey: Self.readerTextSizeKey) ?? ""
        ) ?? .standard
        readerSpacing = ReaderSpacing(
            rawValue: defaults.string(forKey: Self.readerSpacingKey) ?? ""
        ) ?? .comfortable
        showsVerseNumbers = defaults.object(
            forKey: Self.showsVerseNumbersKey
        ).map { _ in defaults.bool(forKey: Self.showsVerseNumbersKey) } ?? true
        searchMode = ScriptureSearchMode(
            rawValue: defaults.string(forKey: Self.searchModeKey) ?? ""
        ) ?? .phrase
        searchScope = ScriptureSearchScope(
            rawValue: defaults.string(forKey: Self.searchScopeKey) ?? ""
        ) ?? .wholeBible
        recentSearches = defaults.stringArray(
            forKey: Self.recentSearchesKey
        ) ?? []
        readingHistory = defaults.data(forKey: Self.readingHistoryKey)
            .flatMap { try? JSONDecoder().decode([ReadingHistoryEntry].self, from: $0) }
            ?? []
    }

    convenience init() {
        do {
            let service = try SwordScriptureService()
            let studyStore = try? StudyStore()
            self.init(service: service, studyStore: studyStore)
        } catch {
            self.init(service: UnavailableScriptureService(error: error))
            presentedError = PresentedError(error)
        }
    }

    func start() async {
        isPresentingOnboarding = !defaults.bool(
            forKey: Self.completedOnboardingKey
        )
        do {
            studyItems = try studyStore?.fetchAll() ?? []
            modules = try await service.installedBibles()
            let saved = defaults.string(forKey: Self.moduleKey)
            let moduleID = modules.contains(where: { $0.id == saved })
                ? saved
                : modules.first?.id

            if let moduleID {
                try await activateModule(moduleID, restoring: true)
            }
        } catch {
            presentedError = PresentedError(error)
        }
    }

    func completeOnboarding() {
        defaults.set(true, forKey: Self.completedOnboardingKey)
        isPresentingOnboarding = false
        if modules.isEmpty {
            section = .library
        }
    }

    func setReaderFont(_ font: ReaderFont) {
        readerFont = font
        defaults.set(font.rawValue, forKey: Self.readerFontKey)
    }

    func setReaderTextSize(_ size: ReaderTextSize) {
        readerTextSize = size
        defaults.set(size.rawValue, forKey: Self.readerTextSizeKey)
    }

    func setReaderSpacing(_ spacing: ReaderSpacing) {
        readerSpacing = spacing
        defaults.set(spacing.rawValue, forKey: Self.readerSpacingKey)
    }

    func setShowsVerseNumbers(_ shows: Bool) {
        showsVerseNumbers = shows
        defaults.set(shows, forKey: Self.showsVerseNumbersKey)
    }

    func setSearchMode(_ mode: ScriptureSearchMode) {
        searchMode = mode
        defaults.set(mode.rawValue, forKey: Self.searchModeKey)
    }

    func setSearchScope(_ scope: ScriptureSearchScope) {
        searchScope = scope
        defaults.set(scope.rawValue, forKey: Self.searchScopeKey)
    }

    func clearRecentSearches() {
        recentSearches = []
        defaults.removeObject(forKey: Self.recentSearchesKey)
    }

    func isBookmarked(reference: String) -> Bool {
        guard let selectedModuleID else { return false }
        return studyItems.contains {
            $0.kind == .bookmark
                && $0.moduleID == selectedModuleID
                && $0.reference == reference
        }
    }

    func note(reference: String) -> String? {
        guard let selectedModuleID else { return nil }
        return studyItems.first {
            $0.kind == .note
                && $0.moduleID == selectedModuleID
                && $0.reference == reference
        }?.text
    }

    func toggleBookmark(reference: String) async {
        guard let selectedModuleID, let studyStore else { return }
        do {
            try studyStore.toggleBookmark(
                moduleID: selectedModuleID,
                reference: reference
            )
            studyItems = try studyStore.fetchAll()
        } catch {
            presentedError = PresentedError(error)
        }
    }

    func saveNote(_ text: String, reference: String) async {
        guard let selectedModuleID, let studyStore else { return }
        do {
            try studyStore.saveNote(
                text,
                moduleID: selectedModuleID,
                reference: reference
            )
            studyItems = try studyStore.fetchAll()
        } catch {
            presentedError = PresentedError(error)
        }
    }

    var reference: String {
        guard let selectedBook else { return "" }
        return "\(selectedBook.name) \(selectedChapter)"
    }

    var selectedBook: BibleBook? {
        books.first { $0.id == selectedBookID }
    }

    var currentDestination: ReaderDestination? {
        guard let selectedModuleID, !reference.isEmpty else { return nil }
        return ReaderDestination(moduleID: selectedModuleID, reference: reference)
    }

    var canMoveToPreviousChapter: Bool {
        guard let selectedBookID,
              let index = books.firstIndex(where: { $0.id == selectedBookID })
        else { return false }
        return selectedChapter > 1 || index > books.startIndex
    }

    var canMoveToNextChapter: Bool {
        guard let selectedBook,
              let index = books.firstIndex(of: selectedBook)
        else { return false }
        return selectedChapter < selectedBook.chapterCount
            || index < books.index(before: books.endIndex)
    }

    func selectModule(_ moduleID: String) {
        guard moduleID != selectedModuleID else { return }
        Task {
            do {
                try await activateModule(moduleID, restoring: true)
            } catch {
                presentedError = PresentedError(error)
            }
        }
    }

    func select(bookID: String, chapter: Int) {
        guard
            let book = books.first(where: { $0.id == bookID }),
            (1...book.chapterCount).contains(chapter)
        else { return }

        selectedBookID = book.id
        selectedChapter = chapter
        persistLocation()
        rememberReadingLocation()
        loadChapter()
    }

    func open(reference newReference: String) {
        section = .read
        guard let location = location(from: newReference) else { return }
        select(bookID: location.book.id, chapter: location.chapter)
    }

    func open(destination: ReaderDestination) async {
        if let moduleID = destination.moduleID,
           modules.contains(where: { $0.id == moduleID }),
           moduleID != selectedModuleID {
            do {
                try await activateModule(moduleID, restoring: true)
            } catch {
                presentedError = PresentedError(error)
                return
            }
        }
        open(reference: destination.reference)
    }

    func open(url: URL) async {
        guard let destination = ReaderDestination(url: url) else { return }
        await open(destination: destination)
    }

    func clearReadingHistory() {
        readingHistory = []
        defaults.removeObject(forKey: Self.readingHistoryKey)
    }

    func moveChapter(by offset: Int) {
        guard offset == -1 || offset == 1,
              let selectedBook,
              let index = books.firstIndex(of: selectedBook)
        else { return }

        if offset < 0, selectedChapter > 1 {
            select(bookID: selectedBook.id, chapter: selectedChapter - 1)
        } else if offset < 0, index > books.startIndex {
            let previous = books[books.index(before: index)]
            select(bookID: previous.id, chapter: previous.chapterCount)
        } else if offset > 0, selectedChapter < selectedBook.chapterCount {
            select(bookID: selectedBook.id, chapter: selectedChapter + 1)
        } else if offset > 0, index < books.index(before: books.endIndex) {
            let next = books[books.index(after: index)]
            select(bookID: next.id, chapter: 1)
        }
    }

    func compare(with moduleID: String) async {
        guard let selectedModuleID,
              moduleID != selectedModuleID,
              !reference.isEmpty
        else { return }
        comparisonTask?.cancel()
        comparisonModuleID = moduleID
        isLoadingComparison = true
        let task = Task {
            do {
                parallelVerses = try await service.parallelChapter(
                    reference,
                    moduleIDs: [selectedModuleID, moduleID]
                )
            } catch is CancellationError {
                return
            } catch {
                presentedError = PresentedError(error)
            }
            isLoadingComparison = false
        }
        comparisonTask = task
        await task.value
    }

    func endComparison() {
        comparisonTask?.cancel()
        comparisonTask = nil
        comparisonModuleID = nil
        parallelVerses = []
        isLoadingComparison = false
    }

    func search(_ query: String) {
        searchTask?.cancel()
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty, let selectedModuleID else {
            searchResults = []
            isSearching = false
            searchProgress = nil
            return
        }

        isSearching = true
        searchProgress = 0
        rememberSearch(normalized)
        let mode = searchMode
        let scope = searchScope
        let generation = UUID()
        searchGeneration = generation
        searchTask = Task {
            do {
                searchResults = try await service.search(
                    normalized,
                    moduleID: selectedModuleID,
                    mode: mode,
                    scope: scope
                ) { [weak self] percentage in
                    Task { @MainActor in self?.searchProgress = percentage }
                }
            } catch is CancellationError {
                // A newer search owns the visible state.
            } catch {
                presentedError = PresentedError(error)
            }
            guard searchGeneration == generation else { return }
            isSearching = false
            searchProgress = nil
        }
    }

    private func rememberSearch(_ query: String) {
        recentSearches.removeAll {
            $0.caseInsensitiveCompare(query) == .orderedSame
        }
        recentSearches.insert(query, at: 0)
        recentSearches = Array(recentSearches.prefix(8))
        defaults.set(recentSearches, forKey: Self.recentSearchesKey)
    }

    func inspectCatalog(at directory: URL) async {
        let hasAccess = directory.startAccessingSecurityScopedResource()
        defer { if hasAccess { directory.stopAccessingSecurityScopedResource() } }
        do {
            catalog = try await service.catalog(at: directory)
        } catch {
            presentedError = PresentedError(error)
        }
    }

    func install(_ module: CatalogModule) async {
        guard let catalog else { return }
        let hasAccess = catalog.directory.startAccessingSecurityScopedResource()
        defer { if hasAccess { catalog.directory.stopAccessingSecurityScopedResource() } }
        isInstalling = true
        defer { isInstalling = false }
        do {
            try await service.install(moduleID: module.id, from: catalog)
            modules = try await service.installedBibles()
            try await activateModule(module.id, restoring: true)
            self.catalog = nil
        } catch {
            presentedError = PresentedError(error)
        }
    }

    func refreshRemoteCatalog() async {
        guard !isRefreshingRemoteCatalog else { return }
        isRefreshingRemoteCatalog = true
        defer { isRefreshingRemoteCatalog = false }
        do {
            remoteModules = try await service.remoteBibles().sorted {
                if $0.id == "ASV" { return true }
                if $1.id == "ASV" { return false }
                return $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        } catch is CancellationError {
            return
        } catch {
            presentedError = PresentedError(error)
        }
    }

    func installRemote(_ module: CatalogModule) async {
        guard installingModuleID == nil else { return }
        installingModuleID = module.id
        installProgress = nil

        let task = Task {
            try await service.installRemote(moduleID: module.id) { [weak self] progress in
                Task { @MainActor in self?.installProgress = progress }
            }
        }
        remoteInstallTask = task

        do {
            try await task.value
            modules = try await service.installedBibles()
            try await activateModule(module.id, restoring: true)
        } catch is CancellationError {
            // Cancellation is an explicit user action, not an error to present.
        } catch {
            presentedError = PresentedError(error)
        }
        remoteInstallTask = nil
        installingModuleID = nil
        installProgress = nil
    }

    func cancelRemoteInstall() {
        remoteInstallTask?.cancel()
    }

    func removeModule(id moduleID: String) async {
        guard modules.contains(where: { $0.id == moduleID }) else { return }
        removingModuleID = moduleID
        defer { removingModuleID = nil }

        do {
            try await service.remove(moduleID: moduleID)
            defaults.removeObject(forKey: Self.bookKeyPrefix + moduleID)
            defaults.removeObject(forKey: Self.chapterKeyPrefix + moduleID)
            modules = try await service.installedBibles()

            guard selectedModuleID == moduleID else { return }
            chapterTask?.cancel()
            searchTask?.cancel()
            isLoading = false
            isSearching = false
            if let replacement = modules.first?.id {
                try await activateModule(replacement, restoring: true)
            } else {
                defaults.removeObject(forKey: Self.moduleKey)
                selectedModuleID = nil
                selectedBookID = nil
                selectedChapter = 1
                books = []
                chapter = nil
                searchResults = []
                section = .library
            }
        } catch {
            presentedError = PresentedError(error)
        }
    }

    private func loadChapter() {
        chapterTask?.cancel()
        guard let selectedModuleID, !reference.isEmpty else {
            chapter = nil
            return
        }
        isLoading = true
        chapterTask = Task {
            do {
                chapter = try await service.chapter(reference, moduleID: selectedModuleID)
            } catch is CancellationError {
                return
            } catch {
                presentedError = PresentedError(error)
            }
            isLoading = false
        }
    }

    private func activateModule(
        _ moduleID: String,
        restoring: Bool
    ) async throws {
        let availableBooks = try await service.books(moduleID: moduleID)
        selectedModuleID = moduleID
        defaults.set(moduleID, forKey: Self.moduleKey)
        books = availableBooks

        guard !availableBooks.isEmpty else {
            selectedBookID = nil
            chapter = nil
            return
        }

        let savedBookID = restoring
            ? defaults.string(forKey: Self.bookKeyPrefix + moduleID)
            : nil
        let savedChapter = restoring
            ? defaults.integer(forKey: Self.chapterKeyPrefix + moduleID)
            : 0
        let savedBook = availableBooks.first { $0.id == savedBookID }
        let fallback = availableBooks.first { $0.id == "John" }
            ?? availableBooks[0]
        let book = savedBook ?? fallback
        let chapter = savedBook.map {
            min(max(savedChapter, 1), $0.chapterCount)
        } ?? min(3, book.chapterCount)

        selectedBookID = book.id
        selectedChapter = chapter
        persistLocation()
        loadChapter()
    }

    private func persistLocation() {
        guard let selectedModuleID, let selectedBookID else { return }
        defaults.set(
            selectedBookID,
            forKey: Self.bookKeyPrefix + selectedModuleID
        )
        defaults.set(
            selectedChapter,
            forKey: Self.chapterKeyPrefix + selectedModuleID
        )
    }

    private func rememberReadingLocation() {
        guard let selectedModuleID, !reference.isEmpty else { return }
        readingHistory.removeAll {
            $0.moduleID == selectedModuleID && $0.reference == reference
        }
        readingHistory.insert(
            ReadingHistoryEntry(
                moduleID: selectedModuleID,
                reference: reference,
                visitedAt: .now
            ),
            at: 0
        )
        readingHistory = Array(readingHistory.prefix(50))
        if let data = try? JSONEncoder().encode(readingHistory) {
            defaults.set(data, forKey: Self.readingHistoryKey)
        }
    }

    private func location(
        from reference: String
    ) -> (book: BibleBook, chapter: Int)? {
        let chapterReference = Self.chapterReference(from: reference)
        let parts = chapterReference.split(whereSeparator: \.isWhitespace)

        guard let chapterPart = parts.last,
              let chapter = Int(chapterPart)
        else { return nil }

        let bookPart = parts.dropLast().joined(separator: " ")
        let book = books.first {
            [$0.id, $0.name, $0.abbreviation].contains {
                $0.caseInsensitiveCompare(bookPart) == .orderedSame
            }
        }

        guard let book, (1...book.chapterCount).contains(chapter) else {
            return nil
        }
        return (book, chapter)
    }

    static func chapterReference(from reference: String) -> String {
        reference.split(separator: ":", maxSplits: 1).first.map(String.init) ?? reference
    }
}

struct PresentedError: Identifiable {
    let id = UUID()
    let message: String

    init(_ error: any Error) {
        message = error.localizedDescription
    }
}

private actor UnavailableScriptureService: ScriptureServing {
    let error: any Error

    init(error: any Error) {
        self.error = error
    }

    func installedBibles() async throws -> [BibleModule] { throw error }
    func books(moduleID: String) async throws -> [BibleBook] { throw error }
    func chapter(_ reference: String, moduleID: String) async throws -> BibleChapter { throw error }
    func parallelChapter(
        _ reference: String,
        moduleIDs: [String]
    ) async throws -> [ParallelVerse] { throw error }
    func search(
        _ query: String,
        moduleID: String,
        mode: ScriptureSearchMode,
        scope: ScriptureSearchScope,
        progress: @escaping @Sendable (Int) -> Void
    ) async throws -> [BibleSearchResult] { throw error }
    func catalog(at directory: URL) async throws -> LocalCatalog { throw error }
    func install(moduleID: String, from catalog: LocalCatalog) async throws { throw error }
    func remoteBibles() async throws -> [CatalogModule] { throw error }
    func installRemote(
        moduleID: String,
        progress: @escaping @Sendable (ModuleTransferProgress) -> Void
    ) async throws { throw error }
    func remove(moduleID: String) async throws { throw error }
}
