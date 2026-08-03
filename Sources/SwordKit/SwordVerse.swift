/// A verse retrieved from a biblical SWORD module.
public struct SwordVerse: Hashable, Sendable {
    /// The reference as resolved by the SWORD engine.
    public let reference: SwordReference

    /// The module identifier from which the verse was retrieved.
    public let moduleName: String

    /// The rendered verse content returned by SWORD.
    public let text: String

    /// Lexical annotations supplied by the SWORD module for this entry.
    public let lexicalAttributes: [SwordLexicalAttribute]

    /// Creates a retrieved verse value.
    public init(
        reference: SwordReference,
        moduleName: String,
        text: String,
        lexicalAttributes: [SwordLexicalAttribute] = []
    ) {
        self.reference = reference
        self.moduleName = moduleName
        self.text = text
        self.lexicalAttributes = lexicalAttributes
    }
}

/// Per-word lexical metadata emitted by a SWORD module.
public struct SwordLexicalAttribute: Hashable, Sendable {
    public let text: String
    public let lemma: String

    /// A normalized Strong's identifier when the lemma contains one.
    public var strongsNumber: String? {
        lemma.split(whereSeparator: { $0.isWhitespace }).lazy
            .map { component in
                component.hasPrefix("strong:")
                    ? component.dropFirst("strong:".count)
                    : component[...]
            }
            .map(String.init)
            .first { value in
                guard let prefix = value.first else { return false }
                return (prefix == "G" || prefix == "H")
                    && value.dropFirst().allSatisfy(\.isNumber)
                    && value.count > 1
            }
    }

    public init(text: String, lemma: String) {
        self.text = text
        self.lemma = lemma
    }
}
