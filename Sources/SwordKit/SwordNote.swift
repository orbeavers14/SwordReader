import Foundation

/// An immutable note associated with a Scripture reference.
public struct SwordNote: Hashable, Sendable, Identifiable {
    /// A stable identifier suitable for persistence.
    public let id: UUID
    /// The Scripture reference associated with the note.
    public let reference: SwordReference
    /// The module associated with the note, when module-specific.
    public let moduleName: String?
    /// The nonempty, trimmed note text.
    public let content: String
    /// The date the note was created.
    public let createdAt: Date
    /// The date the note was most recently updated.
    public let updatedAt: Date

    /// Creates a validated note.
    public init(
        id: UUID = UUID(),
        reference: SwordReference,
        moduleName: String? = nil,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) throws {
        let content = content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !content.isEmpty else {
            throw SwordError.invalidNoteContent
        }

        self.id = id
        self.reference = reference
        self.moduleName = moduleName
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }

    /// Returns a copy containing new note text and an updated modification date.
    public func updating(
        content: String,
        at date: Date = Date()
    ) throws -> SwordNote {
        try SwordNote(
            id: id,
            reference: reference,
            moduleName: moduleName,
            content: content,
            createdAt: createdAt,
            updatedAt: date
        )
    }
}
