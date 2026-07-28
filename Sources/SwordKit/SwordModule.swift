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
