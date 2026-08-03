import Foundation

/// A serializable UTF-16 text range.
public struct SwordTextRange: Hashable, Sendable {
    /// The zero-based UTF-16 offset of the range.
    public let location: Int
    /// The positive UTF-16 length of the range.
    public let length: Int

    /// Creates a validated text range.
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
    /// A stable identifier suitable for persistence.
    public let id: UUID
    /// The highlighted Scripture reference.
    public let reference: SwordReference
    /// The module associated with the highlight, when module-specific.
    public let moduleName: String?
    /// An application-defined highlight style identifier.
    public let styleIdentifier: String
    /// The highlighted substring, or `nil` when the whole verse is highlighted.
    public let range: SwordTextRange?
    /// The date the highlight was created.
    public let createdAt: Date

    /// Creates a validated whole-verse or partial-verse highlight.
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
