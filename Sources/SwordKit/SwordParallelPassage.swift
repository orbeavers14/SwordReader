import Foundation

/// A passage retrieved from multiple Bible modules in caller-supplied order.
public struct SwordParallelPassage: Hashable, Sendable {
    /// The requested Scripture range.
    public let reference: SwordPassageRange

    /// One passage for each requested Bible module.
    public let passages: [SwordPassage]

    /// Expected references absent from each module's returned passage.
    public var missingReferences: [String: [SwordReference]] {
        let expected = expectedReferences

        return Dictionary(
            passages.map { passage in
                let available = Set(passage.verses.map(\.reference))
                return (
                    passage.moduleName,
                    expected.filter { !available.contains($0) }
                )
            },
            uniquingKeysWith: { _, latest in latest }
        )
    }

    /// Reference-keyed rows for side-by-side presentation.
    public var alignedVerses: [SwordAlignedVerse] {
        expectedReferences.map { expected in
            SwordAlignedVerse(
                reference: expected,
                versesByModule: Dictionary(
                    passages.compactMap { passage in
                        guard let verse = passage.verses.first(
                            where: { $0.reference == expected }
                        ) else {
                            return nil
                        }

                        return (passage.moduleName, verse)
                    },
                    uniquingKeysWith: { _, latest in latest }
                )
            )
        }
    }

    public init(
        reference: SwordPassageRange,
        passages: [SwordPassage]
    ) {
        self.reference = reference
        self.passages = passages
    }

    private var expectedReferences: [SwordReference] {
        guard
            let colon = reference.start.value.lastIndex(of: ":"),
            let startingVerse = Int(
                reference.start.value[
                    reference.start.value.index(after: colon)...
                ]
            )
        else {
            return []
        }

        let prefix = reference.start.value[...colon]

        return (startingVerse...reference.endingVerse).compactMap {
            try? SwordReference("\(prefix)\($0)")
        }
    }
}

/// Verses from multiple modules aligned to one Scripture reference.
public struct SwordAlignedVerse: Hashable, Sendable {
    public let reference: SwordReference
    public let versesByModule: [String: SwordVerse]

    /// A verse-level comparison of rendered text across the aligned modules.
    public var comparison: SwordVerseComparison {
        SwordVerseComparison(
            reference: reference,
            textByModule: versesByModule.mapValues(\.text),
            lexicalAttributesByModule: versesByModule.mapValues(
                \.lexicalAttributes
            )
        )
    }

    public init(
        reference: SwordReference,
        versesByModule: [String: SwordVerse]
    ) {
        self.reference = reference
        self.versesByModule = versesByModule
    }
}

/// Rendered verse text grouped by module for comparison.
public struct SwordVerseComparison: Hashable, Sendable {
    public let reference: SwordReference
    public let textByModule: [String: String]
    public let lexicalAttributesByModule: [String: [SwordLexicalAttribute]]

    /// Unicode-aware word tokens grouped by module.
    public var tokensByModule: [String: [SwordWordToken]] {
        Dictionary(uniqueKeysWithValues: textByModule.map { module, text in
            var remainingAttributes = lexicalAttributesByModule[module] ?? []

            let tokens = text.split { character in
                !character.isLetter && !character.isNumber
            }
            .map { substring in
                let tokenText = String(substring)
                let normalized = SwordWordToken(text: tokenText).normalizedText
                let attributeIndex = remainingAttributes.firstIndex {
                    SwordWordToken(text: $0.text).normalizedText == normalized
                }
                let attribute = attributeIndex.map {
                    remainingAttributes.remove(at: $0)
                }

                return SwordWordToken(
                    text: tokenText,
                    lemma: attribute?.lemma,
                    morphology: attribute?.morphology
                )
            }

            return (module, tokens)
        })
    }

    /// Whether the available modules contain more than one distinct text.
    public var hasTextDifferences: Bool {
        Set(textByModule.values).count > 1
    }

    /// Cross-module token groups sharing a Strong's identifier.
    public var wordLinks: [SwordWordLink] {
        var groupedLocations: [String: [SwordWordLocation]] = [:]

        for (moduleName, tokens) in tokensByModule {
            for (index, token) in tokens.enumerated() {
                guard let strongsNumber = token.strongsNumber else {
                    continue
                }

                let location = SwordWordLocation(
                    moduleName: moduleName,
                    tokenIndex: index,
                    token: token
                )

                groupedLocations[strongsNumber, default: []].append(
                    location
                )
            }
        }

        var links: [SwordWordLink] = []

        for (strongsNumber, locations) in groupedLocations {
            let moduleNames = Set(
                locations.map { $0.moduleName }
            )

            guard moduleNames.count > 1 else {
                continue
            }

            links.append(SwordWordLink(
                strongsNumber: strongsNumber,
                locations: locations.sorted {
                    if $0.moduleName != $1.moduleName {
                        return $0.moduleName < $1.moduleName
                    }

                    return $0.tokenIndex < $1.tokenIndex
                }
            ))
        }

        return links.sorted {
            $0.strongsNumber < $1.strongsNumber
        }
    }

    /// Token locations that do not participate in a cross-module word link.
    public var unlinkedWordLocations: [SwordWordLocation] {
        let linked = Set(wordLinks.flatMap(\.locations))
        var unlinked: [SwordWordLocation] = []

        for (moduleName, tokens) in tokensByModule {
            for (index, token) in tokens.enumerated() {
                let location = SwordWordLocation(
                    moduleName: moduleName,
                    tokenIndex: index,
                    token: token
                )

                if !linked.contains(location) {
                    unlinked.append(location)
                }
            }
        }

        return unlinked.sorted {
            if $0.moduleName != $1.moduleName {
                return $0.moduleName < $1.moduleName
            }

            return $0.tokenIndex < $1.tokenIndex
        }
    }

    public init(
        reference: SwordReference,
        textByModule: [String: String],
        lexicalAttributesByModule: [String: [SwordLexicalAttribute]] = [:]
    ) {
        self.reference = reference
        self.textByModule = textByModule
        self.lexicalAttributesByModule = lexicalAttributesByModule
    }
}

/// A token's position within one module's rendered verse.
public struct SwordWordLocation: Hashable, Sendable {
    public let moduleName: String
    public let tokenIndex: Int
    public let token: SwordWordToken

    public init(
        moduleName: String,
        tokenIndex: Int,
        token: SwordWordToken
    ) {
        self.moduleName = moduleName
        self.tokenIndex = tokenIndex
        self.token = token
    }
}

/// Tokens across modules linked by a shared Strong's identifier.
public struct SwordWordLink: Hashable, Sendable {
    public let strongsNumber: String
    public let locations: [SwordWordLocation]

    public init(
        strongsNumber: String,
        locations: [SwordWordLocation]
    ) {
        self.strongsNumber = strongsNumber
        self.locations = locations
    }
}

/// A word token retaining the exact text supplied by its module.
public struct SwordWordToken: Hashable, Sendable {
    public let text: String
    public let lemma: String?
    public let morphology: String?

    public var strongsNumber: String? {
        lemma.map { SwordLexicalAttribute(text: text, lemma: $0) }
            .flatMap(\.strongsNumber)
    }

    /// A case-folded, canonically composed form used for comparison.
    public var normalizedText: String {
        text.folding(
            options: [.caseInsensitive],
            locale: Locale(identifier: "und")
        ).precomposedStringWithCanonicalMapping
    }

    public init(
        text: String,
        lemma: String? = nil,
        morphology: String? = nil
    ) {
        self.text = text
        self.lemma = lemma
        self.morphology = morphology
    }
}
