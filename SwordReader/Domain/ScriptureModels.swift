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
    let headings: [BibleHeading]
}

struct BibleHeading: Identifiable, Hashable, Sendable {
    var id: String { identifier }
    let identifier: String
    let text: String
}

struct BibleChapter: Hashable, Sendable {
    let reference: String
    let moduleID: String
    let verses: [BibleVerse]
}

struct BibleSearchResult: Identifiable, Hashable, Sendable {
    var id: String { "\(moduleID):\(reference)" }
    let reference: String
    let moduleID: String
    let text: String
    let score: Int
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

enum AppSection: String, CaseIterable, Identifiable, Sendable {
    case read
    case search
    case library

    var id: Self { self }

    var title: String {
        switch self {
        case .read: "Read"
        case .search: "Search"
        case .library: "Library"
        }
    }

    var systemImage: String {
        switch self {
        case .read: "book.pages"
        case .search: "magnifyingglass"
        case .library: "books.vertical"
        }
    }
}
