import Foundation

/// An immutable bookmark for a Scripture reference.
public struct SwordBookmark: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let reference: SwordReference
    public let moduleName: String?
    public let label: String?
    public let createdAt: Date

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
