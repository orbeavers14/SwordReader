import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var section: AppSection = .read
    private(set) var modules: [BibleModule] = []
    private(set) var selectedModuleID: String?
    private(set) var books: [BibleBook] = []
    private(set) var selectedBookID: String?
    private(set) var selectedChapter = 1
    private(set) var chapter: BibleChapter?
    private(set) var searchResults: [BibleSearchResult] = []
    private(set) var catalog: LocalCatalog?
    private(set) var isLoading = false
    private(set) var isSearching = false
    private(set) var isInstalling = false
    private(set) var removingModuleID: String?
    private(set) var isPresentingOnboarding = false
    var presentedError: PresentedError?

    private let service: any ScriptureServing
    private let defaults: UserDefaults
    private var chapterTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private static let moduleKey = "selectedBibleModule"
    private static let bookKeyPrefix = "readerBook."
    private static let chapterKeyPrefix = "readerChapter."
    private static let completedOnboardingKey = "completedOnboarding"

    init(
        service: any ScriptureServing,
        defaults: UserDefaults = .standard
    ) {
        self.service = service
        self.defaults = defaults
    }

    convenience init() {
        do {
            try self.init(service: SwordScriptureService())
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

    var reference: String {
        guard let selectedBook else { return "" }
        return "\(selectedBook.name) \(selectedChapter)"
    }

    var selectedBook: BibleBook? {
        books.first { $0.id == selectedBookID }
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
        loadChapter()
    }

    func open(reference newReference: String) {
        section = .read
        guard let location = location(from: newReference) else { return }
        select(bookID: location.book.id, chapter: location.chapter)
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

    func search(_ query: String) {
        searchTask?.cancel()
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty, let selectedModuleID else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            do {
                searchResults = try await service.search(normalized, moduleID: selectedModuleID)
            } catch is CancellationError {
                return
            } catch {
                presentedError = PresentedError(error)
            }
            isSearching = false
        }
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
    func search(_ query: String, moduleID: String) async throws -> [BibleSearchResult] { throw error }
    func catalog(at directory: URL) async throws -> LocalCatalog { throw error }
    func install(moduleID: String, from catalog: LocalCatalog) async throws { throw error }
    func remove(moduleID: String) async throws { throw error }
}
