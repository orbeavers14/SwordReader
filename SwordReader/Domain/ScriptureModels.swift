import Foundation

struct BibleModule: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let language: String
    let version: String?
    let copyright: String?
}

enum ModuleContentCategory: String, Hashable, Sendable {
    case bible
    case commentary
    case dictionary
    case generalBook
    case devotional
    case other

    var title: String {
        switch self {
        case .bible: String(localized: "Bible")
        case .commentary: String(localized: "Commentary")
        case .dictionary: String(localized: "Dictionary")
        case .generalBook: String(localized: "Book")
        case .devotional: String(localized: "Devotional")
        case .other: String(localized: "Other")
        }
    }

    var supportsReading: Bool {
        switch self {
        case .bible, .dictionary, .generalBook, .devotional: true
        case .commentary, .other: false
        }
    }
}

struct KeyedModule: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let language: String
    let version: String?
    let copyright: String?
    let category: ModuleContentCategory
}

struct KeyedModuleEntry: Hashable, Sendable {
    let key: String
    let text: String
    let html: String
}

struct BibleBook: Identifiable, Hashable, Sendable {
    enum Testament: Hashable, Sendable {
        case old
        case new
    }

    let id: String
    let name: String
    let abbreviation: String
    let chapterCount: Int
    let testament: Testament
}

struct BibleVerse: Identifiable, Hashable, Sendable {
    var id: String { reference }
    let reference: String
    let number: String
    let text: String
    let content: AttributedString
    let headings: [BibleHeading]
    let footnotes: [BibleFootnote]
    let crossReferences: [BibleCrossReference]

    var annotationCount: Int {
        footnotes.count + crossReferences.reduce(0) { $0 + $1.references.count }
    }
}

struct BibleHeading: Identifiable, Hashable, Sendable {
    var id: String { identifier }
    let identifier: String
    let text: String
}

struct BibleFootnote: Identifiable, Hashable, Sendable {
    let id: String
    let text: String
    let type: String?
}

struct BibleCrossReference: Identifiable, Hashable, Sendable {
    let id: String
    let references: [String]
}

struct BibleChapter: Hashable, Sendable {
    let reference: String
    let moduleID: String
    let verses: [BibleVerse]
}

struct ParallelVerse: Identifiable, Hashable, Sendable {
    var id: String { reference }
    let reference: String
    let texts: [ParallelVerseText]
    let lexicalLinks: [OriginalLanguageLink]
}

struct ParallelVerseText: Identifiable, Hashable, Sendable {
    var id: String { moduleID }
    let moduleID: String
    let text: String?
}

struct OriginalLanguageLink: Identifiable, Hashable, Sendable {
    var id: String { strongsNumber }
    let strongsNumber: String
    let words: [String]
}

struct BibleSearchResult: Identifiable, Hashable, Sendable {
    var id: String { "\(moduleID):\(reference)" }
    let reference: String
    let moduleID: String
    let text: String
    let score: Int
}

enum ScriptureSearchMode: String, CaseIterable, Identifiable, Sendable {
    case phrase
    case allWords
    case regularExpression
    case strongs
    case morphology

    var id: Self { self }

    var title: String {
        switch self {
        case .phrase: String(localized: "Phrase")
        case .allWords: String(localized: "All Words")
        case .regularExpression: String(localized: "Pattern")
        case .strongs: String(localized: "Strong’s")
        case .morphology: String(localized: "Morphology")
        }
    }
}

enum ScriptureSearchScope: String, CaseIterable, Identifiable, Sendable {
    case wholeBible
    case oldTestament
    case newTestament

    var id: Self { self }

    var title: String {
        switch self {
        case .wholeBible: String(localized: "Whole Bible")
        case .oldTestament: String(localized: "Old Testament")
        case .newTestament: String(localized: "New Testament")
        }
    }
}

struct CatalogModule: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let language: String
    let version: String?
    let copyright: String?
    let category: ModuleContentCategory
    let sourceID: String

    var isBible: Bool { category == .bible }

    init(
        id: String,
        title: String,
        language: String,
        version: String?,
        copyright: String?,
        category: ModuleContentCategory,
        sourceID: String
    ) {
        self.id = id
        self.title = title
        self.language = language
        self.version = version
        self.copyright = copyright
        self.category = category
        self.sourceID = sourceID
    }

    init(
        id: String,
        title: String,
        language: String,
        version: String?,
        copyright: String?,
        isBible: Bool,
        sourceID: String
    ) {
        self.init(
            id: id,
            title: title,
            language: language,
            version: version,
            copyright: copyright,
            category: isBible ? .bible : .other,
            sourceID: sourceID
        )
    }

    var compatibility: ModuleCompatibility {
        if !category.supportsReading { return .unsupportedCategory }
        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            language.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingMetadata
        }
        return .compatible
    }
}

enum ModuleCompatibility: String, Hashable, Sendable {
    case compatible
    case unsupportedCategory
    case missingMetadata

    var title: String {
        switch self {
        case .compatible: String(localized: "Compatible")
        case .unsupportedCategory: String(localized: "Unsupported module category")
        case .missingMetadata: String(localized: "Missing required metadata")
        }
    }
}

enum CatalogFilter {
    static func availableLanguages(in modules: [CatalogModule]) -> [String] {
        Array(Set(modules.lazy
            .map(\.language)
            .filter { !$0.isEmpty }))
            .sorted { languageName(for: $0).localizedStandardCompare(languageName(for: $1)) == .orderedAscending }
    }

    static func apply(
        to modules: [CatalogModule],
        query: String,
        language: String?
    ) -> [CatalogModule] {
        modules.filter { module in
            guard language == nil || module.language == language else { return false }
            guard !query.isEmpty else { return true }
            return [module.title, module.id, module.language, languageName(for: module.language)]
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    static func languageName(for code: String) -> String {
        Locale.current.localizedString(forLanguageCode: code) ?? code
    }
}

struct ModuleSource: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let name: String
    let host: String
    let catalogPath: String
    let packagePath: String
    let isCurated: Bool

    static let crossWire = ModuleSource(
        id: "crosswire",
        name: "CrossWire Bible Society",
        host: "www.crosswire.org",
        catalogPath: "/ftpmirror/pub/sword/raw",
        packagePath: "/ftpmirror/pub/sword/packages/rawzip",
        isCurated: true
    )

    static let eBible = ModuleSource(
        id: "ebible",
        name: "eBible.org",
        host: "ebible.org",
        catalogPath: "/sword",
        packagePath: "/sword/zip",
        isCurated: true
    )

    static func validated(
        name: String,
        host: String,
        catalogPath: String,
        packagePath: String
    ) throws -> ModuleSource {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanHost = host.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanCatalog = catalogPath.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPackages = packagePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty,
              !cleanHost.isEmpty,
              !cleanHost.contains("://"),
              !cleanHost.contains("/"),
              cleanHost.contains("."),
              Self.isSafePath(cleanCatalog),
              Self.isSafePath(cleanPackages)
        else { throw ModuleSourceError.invalidEndpoint }

        let identifier = "custom-" + cleanHost + "-" + String(
            cleanCatalog.unicodeScalars.reduce(into: UInt64(5381)) {
                $0 = (($0 << 5) &+ $0) &+ UInt64($1.value)
            },
            radix: 16
        )
        return ModuleSource(
            id: identifier,
            name: cleanName,
            host: cleanHost,
            catalogPath: cleanCatalog,
            packagePath: cleanPackages,
            isCurated: false
        )
    }

    private static func isSafePath(_ path: String) -> Bool {
        path.hasPrefix("/") && !path.contains("..") && !path.contains("\\")
    }
}

enum ModuleSourceError: LocalizedError {
    case invalidEndpoint

    var errorDescription: String? {
        String(localized: "Enter a valid HTTPS host and absolute catalog and package paths.")
    }
}

struct LocalCatalog: Hashable, Sendable {
    let directory: URL
    let modules: [CatalogModule]
}

struct ModuleTransferProgress: Hashable, Sendable {
    let completedBytes: UInt64
    let totalBytes: UInt64

    var fractionCompleted: Double? {
        guard totalBytes > 0 else { return nil }
        return min(Double(completedBytes) / Double(totalBytes), 1)
    }
}

enum ReaderFont: String, CaseIterable, Identifiable, Sendable {
    case system
    case serif
    case rounded

    var id: Self { self }

    var title: String {
        switch self {
        case .system: String(localized: "System")
        case .serif: String(localized: "Serif")
        case .rounded: String(localized: "Rounded")
        }
    }
}

enum ReaderTextSize: String, CaseIterable, Identifiable, Sendable {
    case small
    case standard
    case large
    case extraLarge

    var id: Self { self }

    var title: String {
        switch self {
        case .small: String(localized: "Small")
        case .standard: String(localized: "Default")
        case .large: String(localized: "Large")
        case .extraLarge: String(localized: "Extra Large")
        }
    }
}

enum ReaderSpacing: String, CaseIterable, Identifiable, Sendable {
    case compact
    case comfortable
    case relaxed

    var id: Self { self }

    var title: String {
        switch self {
        case .compact: String(localized: "Compact")
        case .comfortable: String(localized: "Comfortable")
        case .relaxed: String(localized: "Relaxed")
        }
    }
}

enum AppAppearance: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    var id: Self { self }

    var title: String {
        switch self {
        case .system: String(localized: "System")
        case .light: String(localized: "Light")
        case .dark: String(localized: "Dark")
        }
    }
}

struct StudyItem: Identifiable, Hashable, Sendable {
    enum Kind: String, Hashable, Sendable {
        case bookmark
        case note
    }

    var id: String { "\(kind.rawValue):\(moduleID):\(reference)" }
    let kind: Kind
    let moduleID: String
    let reference: String
    let text: String?
}

enum AppSection: String, CaseIterable, Identifiable, Sendable {
    case read
    case plans
    case search
    case library

    var id: Self { self }

    var title: String {
        switch self {
        case .read: String(localized: "Read")
        case .plans: String(localized: "Plans")
        case .search: String(localized: "Search")
        case .library: String(localized: "Library")
        }
    }

    var systemImage: String {
        switch self {
        case .read: "book.pages"
        case .plans: "calendar"
        case .search: "magnifyingglass"
        case .library: "books.vertical"
        }
    }
}

struct ReadingPlanSelection: Codable, Hashable, Sendable {
    let planID: String
    let startedAt: Date
    var completedDayIDs: Set<Int>
}

struct ReaderDestination: Codable, Hashable, Sendable {
    let moduleID: String?
    let reference: String

    init(moduleID: String? = nil, reference: String) {
        self.moduleID = moduleID
        self.reference = reference
    }

    init?(url: URL) {
        guard url.scheme?.lowercased() == "swordreader",
              url.host?.lowercased() == "read",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let reference = components.queryItems?.first(
                where: { $0.name == "reference" }
              )?.value,
              !reference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }

        self.reference = reference
        moduleID = components.queryItems?.first { $0.name == "module" }?.value
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = "swordreader"
        components.host = "read"
        components.queryItems = [
            URLQueryItem(name: "reference", value: reference),
            moduleID.map { URLQueryItem(name: "module", value: $0) }
        ].compactMap { $0 }
        return components.url
    }
}

struct ReadingHistoryEntry: Codable, Identifiable, Hashable, Sendable {
    var id: String { "\(moduleID):\(reference)" }
    let moduleID: String
    let reference: String
    let visitedAt: Date
}
