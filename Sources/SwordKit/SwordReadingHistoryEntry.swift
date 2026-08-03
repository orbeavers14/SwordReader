import Foundation

/// An immutable record of a Scripture reference being accessed.
public struct SwordReadingHistoryEntry: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let reference: SwordReference
    public let moduleName: String?
    public let accessedAt: Date

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
