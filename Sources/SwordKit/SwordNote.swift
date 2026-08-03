import Foundation

/// An immutable note associated with a Scripture reference.
public struct SwordNote: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let reference: SwordReference
    public let moduleName: String?
    public let content: String
    public let createdAt: Date
    public let updatedAt: Date

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
