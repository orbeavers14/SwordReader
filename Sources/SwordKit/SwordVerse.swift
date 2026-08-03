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
    public let footnotes: [SwordFootnote]
    public let crossReferences: [SwordCrossReference]
    public let headings: [SwordHeading]

    /// Creates a retrieved verse value.
    public init(
        reference: SwordReference,
        moduleName: String,
        text: String,
        lexicalAttributes: [SwordLexicalAttribute] = [],
        footnotes: [SwordFootnote] = [],
        crossReferences: [SwordCrossReference] = [],
        headings: [SwordHeading] = []
    ) {
        self.reference = reference
        self.moduleName = moduleName
        self.text = text
        self.lexicalAttributes = lexicalAttributes
        self.footnotes = footnotes
        self.crossReferences = crossReferences
        self.headings = headings
    }
}

/// A heading associated with a SWORD entry.
public struct SwordHeading: Hashable, Sendable {
    public enum Position: Hashable, Sendable {
        case preVerse
        case interVerse
        case other(String)
    }

    public let identifier: String
    public let body: String
    public let position: Position

    public init(identifier: String, body: String, position: Position) {
        self.identifier = identifier
        self.body = body
        self.position = position
    }
}

/// Scripture references associated with a cross-reference footnote.
public struct SwordCrossReference: Hashable, Sendable {
    public let footnoteIdentifier: String
    public let references: [SwordReference]

    public init(
        footnoteIdentifier: String,
        references: [SwordReference]
    ) {
        self.footnoteIdentifier = footnoteIdentifier
        self.references = references
    }
}

/// Footnote metadata attached to a SWORD entry.
public struct SwordFootnote: Hashable, Sendable {
    public let identifier: String
    public let body: String
    public let type: String?
    public let referenceList: String?

    public init(
        identifier: String,
        body: String,
        type: String? = nil,
        referenceList: String? = nil
    ) {
        self.identifier = identifier
        self.body = body
        self.type = type
        self.referenceList = referenceList
    }
}

/// Per-word lexical metadata emitted by a SWORD module.
public struct SwordLexicalAttribute: Hashable, Sendable {
    public let text: String
    public let lemma: String
    public let morphology: String?

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

    public init(
        text: String,
        lemma: String,
        morphology: String? = nil
    ) {
        self.text = text
        self.lemma = lemma
        self.morphology = morphology
    }
}
