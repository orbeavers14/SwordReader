import Foundation

/// An immutable bookmark for a Scripture reference.
public struct SwordBookmark: Hashable, Sendable, Identifiable {
    /// A stable identifier suitable for persistence.
    public let id: UUID
    /// The bookmarked Scripture reference.
    public let reference: SwordReference
    /// The module associated with the bookmark, when module-specific.
    public let moduleName: String?
    /// An optional user-visible label.
    public let label: String?
    /// The date the bookmark was created.
    public let createdAt: Date

    /// Creates a bookmark, trimming an optional label and treating a blank label as absent.
    public init(
        id: UUID = UUID(),
        reference: SwordReference,
        moduleName: String? = nil,
        label: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.reference = reference
        self.moduleName = moduleName
        self.label = label?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).nilIfEmpty
        self.createdAt = createdAt
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
