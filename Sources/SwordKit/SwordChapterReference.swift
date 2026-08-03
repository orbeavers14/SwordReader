/// A Scripture chapter reference such as `"John 3"`.
public struct SwordChapterReference: Hashable, Sendable {
    /// The original normalized value.
    public let value: String

    /// The book portion of the reference.
    public let book: String

    /// The chapter number.
    public let chapterNumber: Int

    /// The first verse reference in the chapter.
    public var firstVerse: SwordReference {
        get throws {
            try SwordReference("\(book) \(chapterNumber):1")
        }
    }

    /// Parses and validates a chapter reference.
    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty else {
            throw SwordError.invalidChapterReference(value)
        }

        guard !trimmed.contains(":") else {
            throw SwordError.invalidChapterReference(value)
        }

        let parts = trimmed.split(
            whereSeparator: \.isWhitespace
        )

        guard
            parts.count >= 2,
            let chapterNumber = Int(parts.last!),
            chapterNumber > 0
        else {
            throw SwordError.invalidChapterReference(value)
        }

        let book = parts.dropLast().joined(separator: " ")

        guard !book.isEmpty else {
            throw SwordError.invalidChapterReference(value)
        }

        self.value = "\(book) \(chapterNumber)"
        self.book = book
        self.chapterNumber = chapterNumber
    }
}
