/// A matching entry returned by a SWORD module search.
public struct SwordSearchResult: Hashable, Sendable {
    /// The reference containing the match.
    public let reference: SwordReference

    /// The module identifier from which the result was retrieved.
    public let moduleName: String

    /// The rendered content of the matching entry.
    public let text: String

    /// The relevance score reported by the SWORD engine.
    public let score: Int

    /// Creates a search result value.
    public init(
        reference: SwordReference,
        moduleName: String,
        text: String,
        score: Int
    ) {
        self.reference = reference
        self.moduleName = moduleName
        self.text = text
        self.score = score
    }
}

public extension Collection where Element == SwordSearchResult {
    /// Returns the results ordered by descending SWORD relevance score.
    ///
    /// Results with equal scores retain their original relative order.
    func rankedByRelevance() -> [SwordSearchResult] {
        enumerated()
            .sorted { lhs, rhs in
                if lhs.element.score != rhs.element.score {
                    return lhs.element.score > rhs.element.score
                }

                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }
}
