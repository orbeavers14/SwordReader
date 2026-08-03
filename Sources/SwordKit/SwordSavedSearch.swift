import Foundation

/// An immutable, reproducible SwordKit search request.
public struct SwordSavedSearch: Hashable, Sendable, Identifiable {
    public let id: UUID
    public let query: String
    public let type: SwordSearchType
    public let caseSensitive: Bool
    public let scope: String?
    public let moduleName: String?
    public let createdAt: Date

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
