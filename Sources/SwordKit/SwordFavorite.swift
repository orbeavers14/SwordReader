import Foundation

/// An immutable favorite Scripture reference.
public struct SwordFavorite: Hashable, Sendable, Identifiable {
    /// A stable identifier suitable for persistence.
    public let id: UUID
    /// The favorited Scripture reference.
    public let reference: SwordReference
    /// The module associated with the favorite, when module-specific.
    public let moduleName: String?
    /// The date the favorite was created.
    public let createdAt: Date

    /// Creates a favorite Scripture reference.
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
