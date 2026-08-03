import Foundation

/// An immutable, reproducible SwordKit search request.
public struct SwordSavedSearch: Hashable, Sendable, Identifiable {
    /// A stable identifier suitable for persistence.
    public let id: UUID
    /// The nonempty, trimmed search query.
    public let query: String
    /// The search matching strategy.
    public let type: SwordSearchType
    /// Whether letter case must match.
    public let caseSensitive: Bool
    /// An optional Scripture expression limiting the search.
    public let scope: String?
    /// The module associated with the search, when module-specific.
    public let moduleName: String?
    /// The date the saved search was created.
    public let createdAt: Date

    /// Creates a validated, reproducible saved search.
    public init(
        id: UUID = UUID(),
        query: String,
        type: SwordSearchType = .phrase,
        caseSensitive: Bool = true,
        scope: String? = nil,
        moduleName: String? = nil,
        createdAt: Date = Date()
    ) throws {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let scope = scope?.trimmingCharacters(in: .whitespacesAndNewlines)
        let moduleName = moduleName?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            throw SwordError.invalidSearchQuery(query)
        }

        if let scope, scope.isEmpty {
            throw SwordError.invalidReferenceList(scope)
        }

        self.id = id
        self.query = query
        self.type = type
        self.caseSensitive = caseSensitive
        self.scope = scope
        self.moduleName = moduleName?.isEmpty == true ? nil : moduleName
        self.createdAt = createdAt
    }
}
