import Foundation

struct BibleModule: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let language: String
    let version: String?
    let copyright: String?
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
        case .phrase: "Phrase"
        case .allWords: "All Words"
        case .regularExpression: "Pattern"
        case .strongs: "Strong’s"
        case .morphology: "Morphology"
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
        case .wholeBible: "Whole Bible"
        case .oldTestament: "Old Testament"
        case .newTestament: "New Testament"
        }
    }
}

struct CatalogModule: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let language: String
    let version: String?
    let copyright: String?
    let isBible: Bool
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
        case .system: "System"
        case .serif: "Serif"
        case .rounded: "Rounded"
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
        case .small: "Small"
        case .standard: "Default"
        case .large: "Large"
        case .extraLarge: "Extra Large"
        }
    }
}

enum ReaderSpacing: String, CaseIterable, Identifiable, Sendable {
    case compact
    case comfortable
    case relaxed

    var id: Self { self }

    var title: String { rawValue.capitalized }
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
        case .read: "Read"
        case .plans: "Plans"
        case .search: "Search"
        case .library: "Library"
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
