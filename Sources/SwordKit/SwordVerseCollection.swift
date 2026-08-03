import Foundation

/// An immutable named collection of portable Scripture references.
public struct SwordVerseCollection: Hashable, Sendable, Identifiable {
    /// A stable identifier suitable for persistence.
    public let id: UUID
    /// The nonempty display title.
    public let title: String
    /// The unique Scripture references in collection order.
    public let references: [SwordReference]
    /// The date the collection was created.
    public let createdAt: Date

    /// Creates a nonempty collection with a unique set of references.
    public init(
        id: UUID = UUID(),
        title: String,
        references: [SwordReference],
        createdAt: Date = Date()
    ) throws {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            !title.isEmpty,
            !references.isEmpty,
            Set(references).count == references.count
        else {
            throw SwordError.invalidVerseCollection(title)
        }

        self.id = id
        self.title = title
        self.references = references
        self.createdAt = createdAt
    }
}
