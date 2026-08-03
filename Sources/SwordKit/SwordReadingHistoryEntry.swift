import Foundation

/// An immutable record of a Scripture reference being accessed.
public struct SwordReadingHistoryEntry: Hashable, Sendable, Identifiable {
    /// A stable identifier suitable for persistence.
    public let id: UUID
    /// The Scripture reference that was accessed.
    public let reference: SwordReference
    /// The module used for the reading, when known.
    public let moduleName: String?
    /// The date the reference was accessed.
    public let accessedAt: Date

    /// Creates a reading-history entry.
    public init(
        id: UUID = UUID(),
        reference: SwordReference,
        moduleName: String? = nil,
        accessedAt: Date = Date()
    ) {
        self.id = id
        self.reference = reference
        self.moduleName = moduleName
        self.accessedAt = accessedAt
    }
}
