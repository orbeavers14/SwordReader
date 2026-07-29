/// A sequential collection of verses retrieved from a SWORD module.
public struct SwordPassage: Hashable, Sendable {
    /// The reference requested for the beginning of the passage.
    public let reference: SwordReference

    /// The module used to retrieve the passage.
    public let moduleName: String

    /// The verses contained in the passage.
    public let verses: [SwordVerse]

    public init(
        reference: SwordReference,
        moduleName: String,
        verses: [SwordVerse]
    ) {
        self.reference = reference
        self.moduleName = moduleName
        self.verses = verses
    }
}
