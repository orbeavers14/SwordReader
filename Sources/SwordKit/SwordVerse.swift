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
    /// Footnotes attached to the entry.
    public let footnotes: [SwordFootnote]
    /// Parsed Scripture cross references attached to the entry.
    public let crossReferences: [SwordCrossReference]
    /// Headings associated with the entry.
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
    /// The heading's position relative to verse content.
    public enum Position: Hashable, Sendable {
        /// The heading precedes the verse.
        case preVerse
        /// The heading occurs within the verse stream.
        case interVerse
        /// A module-specific position value.
        case other(String)
    }

    /// The module-provided heading identifier.
    public let identifier: String
    /// The rendered heading content.
    public let body: String
    /// The heading's position relative to the verse.
    public let position: Position

    /// Creates heading metadata.
    public init(identifier: String, body: String, position: Position) {
        self.identifier = identifier
        self.body = body
        self.position = position
    }
}

/// Scripture references associated with a cross-reference footnote.
public struct SwordCrossReference: Hashable, Sendable {
    /// The identifier of the source footnote.
    public let footnoteIdentifier: String
    /// Scripture references parsed from the footnote.
    public let references: [SwordReference]

    /// Creates parsed cross-reference metadata.
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
    /// The module-provided footnote identifier.
    public let identifier: String
    /// The rendered footnote content.
    public let body: String
    /// The module-provided footnote type, when available.
    public let type: String?
    /// The unparsed reference expression, when provided.
    public let referenceList: String?

    /// Creates footnote metadata.
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
    /// The exact text annotated by the module.
    public let text: String
    /// The module-provided lemma metadata.
    public let lemma: String
    /// The module-provided morphology code, when available.
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

    /// Creates lexical metadata for rendered text.
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
