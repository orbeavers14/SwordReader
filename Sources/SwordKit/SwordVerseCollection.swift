import Foundation

/// An immutable named collection of portable Scripture references.
public struct SwordVerseCollection: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let references: [SwordReference]
    public let createdAt: Date

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
