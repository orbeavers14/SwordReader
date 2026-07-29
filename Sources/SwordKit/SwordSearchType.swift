/// The matching strategy used by a SWORD module search.
public enum SwordSearchType: Hashable, Sendable {
    /// Matches the query as one exact phrase.
    case phrase

    /// Matches entries containing every word in the query.
    case multiWord

    /// Matches entries using a POSIX extended regular expression.
    case regularExpression

    /// Matches entries tagged with a Strong's Greek or Hebrew number.
    case strongs

    /// Matches entries tagged with a morphology code.
    case morphology

    internal var bridgeValue: Int32 {
        switch self {
        case .phrase:
            -1

        case .multiWord:
            -2

        case .regularExpression:
            0

        case .strongs:
            -3

        case .morphology:
            -3
        }
    }

    internal var bridgeAttributeType: Int32 {
        switch self {
        case .phrase, .multiWord, .regularExpression:
            0

        case .strongs:
            1

        case .morphology:
            2
        }
    }

    internal func normalizedQuery(
        _ query: String
    ) throws -> String {
        guard self == .strongs else {
            return query
        }

        guard let first = query.first else {
            throw SwordError.invalidStrongsNumber(query)
        }

        let prefix = String(first).uppercased()
        let digits = String(query.dropFirst())

        guard
            prefix == "G" || prefix == "H",
            !digits.isEmpty,
            digits.allSatisfy({ $0.wholeNumberValue != nil }),
            let number = Int(digits),
            number > 0,
            number <= 99_999
        else {
            throw SwordError.invalidStrongsNumber(query)
        }

        let value = String(number)
        let padding = String(
            repeating: "0",
            count: 5 - value.count
        )

        return prefix + padding + value
    }
}
