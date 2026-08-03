import Foundation

/// A serializable UTF-16 text range.
public struct SwordTextRange: Hashable, Sendable {
    public let location: Int
    public let length: Int

    public init(location: Int, length: Int) throws {
        guard location >= 0, length > 0 else {
            throw SwordError.invalidTextRange(location: location, length: length)
        }

        self.location = location
        self.length = length
    }
}

/// An immutable whole-verse or partial-verse highlight.
public struct SwordHighlight: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let reference: SwordReference
    public let moduleName: String?
    public let styleIdentifier: String
    public let range: SwordTextRange?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        reference: SwordReference,
        moduleName: String? = nil,
        styleIdentifier: String,
        range: SwordTextRange? = nil,
        createdAt: Date = Date()
    ) throws {
        let styleIdentifier = styleIdentifier.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !styleIdentifier.isEmpty else {
            throw SwordError.invalidHighlightStyle(styleIdentifier)
        }

        self.id = id
        self.reference = reference
        self.moduleName = moduleName
        self.styleIdentifier = styleIdentifier
        self.range = range
        self.createdAt = createdAt
    }
}
