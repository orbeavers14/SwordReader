/// A complete chapter retrieved from a SWORD Bible module.
public struct SwordChapter: Hashable, Sendable {
    /// The normalized chapter reference, such as `"John 3"`.
    public let reference: SwordChapterReference

    /// The module used to retrieve the chapter.
    public let moduleName: String

    /// The verses contained in the chapter.
    public let verses: [SwordVerse]

    public init(
        reference: SwordChapterReference,
        moduleName: String,
        verses: [SwordVerse]
    ) {
        self.reference = reference
        self.moduleName = moduleName
        self.verses = verses
    }
}
