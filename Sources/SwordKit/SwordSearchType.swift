/// The matching strategy used by a SWORD module search.
public enum SwordSearchType: Hashable, Sendable {
    /// Matches the query as one exact phrase.
    case phrase

    /// Matches entries containing every word in the query.
    case multiWord

    internal var bridgeValue: Int32 {
        switch self {
        case .phrase:
            -1

        case .multiWord:
            -2
        }
    }
}
