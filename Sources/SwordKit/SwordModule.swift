import CSwordBridge

/// An installed module provided by the SWORD engine.
///
/// A module may represent a Bible, commentary, dictionary, lexicon,
/// or general book.
public final class SwordModule: Hashable {
    /// The module's internal SWORD identifier.
    public let name: String
    
    /// The human-readable module title or description.
    public let title: String
    
    /// The module's language code.
    public let language: String
    
    /// The general type of content contained in the module.
    public let category: Category
    
    private let storage: SwordManagerStorage
    internal let handle: OpaquePointer
    
    internal init(
        storage: SwordManagerStorage,
        handle: OpaquePointer
    ) {
        self.storage = storage
        self.handle = handle
        
        self.name = SwordLibrary.string(
            from: SwordModuleName(handle)
        )
        
        self.title = SwordLibrary.string(
            from: SwordModuleDescription(handle)
        )
        
        self.language = SwordLibrary.string(
            from: SwordModuleLanguage(handle)
        )
        
        let type = SwordLibrary.string(
            from: SwordModuleType(handle)
        )
        
        self.category = Category(swordType: type)
    }
    
    /// Parses a Scripture reference expression using the module's
    /// native SWORD versification.
    public func references(
        in expression: String
    ) throws -> SwordReferenceList {
        guard category == .bible else {
            throw SwordError.unsupportedModuleType
        }

        let trimmedExpression = expression.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedExpression.isEmpty else {
            throw SwordError.invalidReferenceList(expression)
        }

        SwordModuleClearParsedReferences(handle)

        defer {
            SwordModuleClearParsedReferences(handle)
        }

        let count = trimmedExpression.withCString { pointer in
            SwordModuleParseReferenceCount(
                handle,
                pointer
            )
        }

        guard count > 0 else {
            throw SwordError.invalidReferenceList(expression)
        }

        var references: [SwordReference] = []
        references.reserveCapacity(count)

        for index in 0..<count {
            guard let pointer = SwordModuleParsedReference(
                handle,
                index
            ) else {
                throw SwordError.invalidReferenceList(expression)
            }

            let value = String(cString: pointer)

            guard !value.isEmpty else {
                throw SwordError.invalidReferenceList(expression)
            }

            references.append(
                try SwordReference(value)
            )
        }

        return SwordReferenceList(
            references: references
        )
    }

    /// Retrieves verses from a parsed Scripture reference list.
    ///
    /// Verses are returned in the same order as their references.
    public func verses(
        in references: SwordReferenceList
    ) throws -> [SwordVerse] {
        try references.map(verse)
    }

    /// Parses a Scripture reference expression and retrieves its verses.
    ///
    /// The expression may contain ranges, disjoint references, and
    /// references that span multiple books.
    public func verses(
        in expression: String
    ) throws -> [SwordVerse] {
        try verses(
            in: references(in: expression)
        )
    }

    /// Searches a Bible module for matching entries.
    ///
    /// - Parameters:
    ///   - query: The nonempty text to find.
    ///   - type: The matching strategy. The default is exact phrase search.
    ///   - caseSensitive: Whether letter case must match. The default is `true`.
    /// - Returns: Matching verses in the order returned by SWORD.
    public func search(
        _ query: String,
        type: SwordSearchType = .phrase,
        caseSensitive: Bool = true
    ) throws -> [SwordSearchResult] {
        guard category == .bible else {
            throw SwordError.unsupportedModuleType
        }

        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedQuery.isEmpty else {
            throw SwordError.invalidSearchQuery(query)
        }

        let normalizedQuery = try type.normalizedQuery(
            trimmedQuery
        )

        SwordModuleClearSearchResults(handle)

        defer {
            SwordModuleClearSearchResults(handle)
        }

        let count = normalizedQuery.withCString { pointer in
            SwordModuleSearchCount(
                handle,
                pointer,
                type.bridgeValue,
                type.bridgeAttributeType,
                caseSensitive ? 1 : 0
            )
        }

        var results: [SwordSearchResult] = []
        results.reserveCapacity(count)

        for index in 0..<count {
            guard let pointer = SwordModuleSearchResultReference(
                handle,
                index
            ) else {
                continue
            }

            let value = String(cString: pointer)

            guard !value.isEmpty else {
                continue
            }

            let verse = try verse(SwordReference(value))

            results.append(
                SwordSearchResult(
                    reference: verse.reference,
                    moduleName: verse.moduleName,
                    text: verse.text,
                    score: Int(
                        SwordModuleSearchResultScore(
                            handle,
                            index
                        )
                    )
                )
            )
        }

        return results
    }
    
    /// Retrieves a complete chapter from a Bible module.
    public func chapter(
        _ reference: SwordChapterReference
    ) throws -> SwordChapter {
        guard category == .bible else {
            throw SwordError.unsupportedModuleType
        }

        let firstVerse = try verse(reference.firstVerse)

        var verses = [firstVerse]

        let chapterPrefix = "\(reference.book) \(reference.chapterNumber):"

        while true {
            let previousReference = currentReference

            advance()

            guard let nextVerse = currentVerse else {
                break
            }

            guard nextVerse.reference != previousReference else {
                break
            }

            guard nextVerse.reference.value.hasPrefix(chapterPrefix) else {
                break
            }

            verses.append(nextVerse)
        }

        return SwordChapter(
            reference: reference.value,
            moduleName: name,
            verses: verses
        )
    }

    /// Retrieves a complete chapter using a textual reference.
    public func chapter(
        _ reference: String
    ) throws -> SwordChapter {
        try chapter(
            SwordChapterReference(reference)
        )
    }
    
    /// Retrieves a verse from this module.
    ///
    /// - Parameter reference: A Scripture reference such as
    ///   `"John 3:16"`.
    /// - Returns: The verse and its SWORD-normalized reference.
    /// - Throws: A ``SwordError`` when the reference is invalid,
    ///   unavailable, or incompatible with the module.
    public func verse(
        _ reference: SwordReference
    ) throws -> SwordVerse {
        guard category == .bible else {
            throw SwordError.unsupportedModuleType
        }
        
        let status = reference.value.withCString {
            SwordModuleSetKey(handle, $0)
        }
        
        guard status == 0 else {
            throw SwordError.referenceNotFound(reference.value)
        }
        
        let resolvedValue = SwordLibrary.string(
            from: SwordModuleCurrentKey(handle)
        )
        
        guard !resolvedValue.isEmpty else {
            throw SwordError.missingResolvedReference
        }
        
        let resolvedReference = try SwordReference(resolvedValue)
        
        let text = SwordLibrary.string(
            from: SwordModuleRenderText(handle)
        )
        
        guard !text.isEmpty else {
            throw SwordError.emptyRenderedText(
                reference: resolvedReference.value
            )
        }
        
        return SwordVerse(
            reference: resolvedReference,
            moduleName: name,
            text: text
        )
    }
    
    /// Retrieves a verse using a textual reference.
    ///
    /// This convenience overload creates a ``SwordReference`` before
    /// performing the lookup.
    ///
    /// - Parameter reference: A reference such as `"John 3:16"`.
    /// - Returns: The retrieved verse.
    /// - Throws: A ``SwordError`` when the reference cannot be retrieved.
    public func verse(
        _ reference: String
    ) throws -> SwordVerse {
        try verse(SwordReference(reference))
    }
    
    deinit {
        SwordModuleDestroy(handle)
    }
    
    public static func == (
        lhs: SwordModule,
        rhs: SwordModule
    ) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    /// Retrieves a sequential passage beginning at the supplied reference.
    ///
    /// - Parameters:
    ///   - reference: The first verse in the passage.
    ///   - verseCount: The number of verses to retrieve.
    /// - Returns: A sequential collection of verses.
    /// - Throws: A ``SwordError`` when the request cannot be completed.
    public func passage(
        startingAt reference: SwordReference,
        verseCount: Int
    ) throws -> SwordPassage {
        guard category == .bible else {
            throw SwordError.unsupportedModuleType
        }
        
        guard verseCount > 0 else {
            throw SwordError.invalidVerseCount(verseCount)
        }
        
        let firstVerse = try verse(reference)
        
        var verses = [firstVerse]
        verses.reserveCapacity(verseCount)
        
        while verses.count < verseCount {
            let previousReference = currentReference
            
            advance()
            
            guard let nextVerse = currentVerse else {
                break
            }
            
            guard nextVerse.reference != previousReference else {
                break
            }
            
            verses.append(nextVerse)
        }
        
        return SwordPassage(
            reference: firstVerse.reference,
            moduleName: name,
            verses: verses
        )
    }
    
    /// Retrieves a sequential passage using a textual starting reference.
    public func passage(
        startingAt reference: String,
        verseCount: Int
    ) throws -> SwordPassage {
        try passage(
            startingAt: SwordReference(reference),
            verseCount: verseCount
        )
    }
    /// Retrieves a same-chapter passage using a textual verse range.
    ///
    /// Supported examples include:
    ///
    /// ```swift
    /// try module.passage("John 3:16-21")
    /// try module.passage("1 Corinthians 13:4-8")
    /// ```
    ///
    /// Cross-chapter ranges are not yet supported.
    public func passage(
        _ range: String
    ) throws -> SwordPassage {
        let parsedRange = try SwordPassageRange(range)

        return try passage(
            startingAt: parsedRange.start,
            verseCount: parsedRange.verseCount
        )
    }
}

public extension SwordModule {
    /// A broad classification of a SWORD module's contents.
    enum Category: Hashable, Sendable {
        /// A biblical text or translation.
        case bible

        /// A biblical commentary.
        case commentary

        /// A dictionary or lexicon.
        case dictionary

        /// A general-purpose book.
        case generalBook

        /// A module type not recognized by SwordKit.
        case other(String)

        internal init(swordType: String) {
            switch swordType {
            case "Biblical Texts":
                self = .bible

            case "Commentaries":
                self = .commentary

            case "Lexicons / Dictionaries":
                self = .dictionary

            case "Generic Books":
                self = .generalBook

            default:
                self = .other(swordType)
            }
        }
    }
}

extension SwordModule {
    internal func advance() {
        SwordModuleIncrement(handle)
    }

    internal func retreat() {
        SwordModuleDecrement(handle)
    }

    internal var currentReference: SwordReference? {
        let text = SwordLibrary.string(
            from: SwordModuleCurrentKey(handle)
        )

        return try? SwordReference(text)
    }

    internal var currentText: String {
        SwordLibrary.string(
            from: SwordModuleRenderText(handle)
        )
    }
    
    internal var currentVerse: SwordVerse? {
        guard let reference = currentReference else {
            return nil
        }

        let text = currentText

        guard !text.isEmpty else {
            return nil
        }

        return SwordVerse(
            reference: reference,
            moduleName: name,
            text: text
        )
    }
}
