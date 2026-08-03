import Foundation

/// An immutable favorite Scripture reference.
public struct SwordFavorite: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let reference: SwordReference
    public let moduleName: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        reference: SwordReference,
        moduleName: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.reference = reference
        self.moduleName = moduleName
        self.createdAt = createdAt
    }
}
