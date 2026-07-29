/// A same-chapter Scripture verse range.
///
/// Examples:
///
/// ```swift
/// try SwordPassageRange("John 3:16-21")
/// try SwordPassageRange("1 Corinthians 13:4-8")
/// ```
public struct SwordPassageRange: Hashable, Sendable {
    /// The original textual range.
    public let value: String

    /// The first reference in the range.
    public let start: SwordReference

    /// The final verse number in the range.
    public let endingVerse: Int

    /// The number of verses represented by the range.
    public let verseCount: Int

    /// Creates a same-chapter passage range.
    ///
    /// This initial implementation supports references in the form:
    ///
    /// `Book chapter:startVerse-endVerse`
    ///
    /// It does not yet support cross-chapter ranges.
    public init(_ value: String) throws {
        let trimmed = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmed.isEmpty else {
            throw SwordError.invalidPassageRange(value)
        }

        guard let dashIndex = trimmed.lastIndex(of: "-") else {
            throw SwordError.invalidPassageRange(value)
        }

        let startingPart = String(
            trimmed[..<dashIndex]
        ).trimmingCharacters(in: .whitespaces)

        let endingPart = String(
            trimmed[trimmed.index(after: dashIndex)...]
        ).trimmingCharacters(in: .whitespaces)

        guard
            !startingPart.isEmpty,
            let endingVerse = Int(endingPart),
            endingVerse > 0
        else {
            throw SwordError.invalidPassageRange(value)
        }

        guard let colonIndex = startingPart.lastIndex(of: ":") else {
            throw SwordError.invalidPassageRange(value)
        }

        let startingVerseText = String(
            startingPart[startingPart.index(after: colonIndex)...]
        )

        guard
            let startingVerse = Int(startingVerseText),
            startingVerse > 0
        else {
            throw SwordError.invalidPassageRange(value)
        }

        guard endingVerse >= startingVerse else {
            throw SwordError.reversedPassageRange(value)
        }

        self.value = trimmed
        self.start = try SwordReference(startingPart)
        self.endingVerse = endingVerse
        self.verseCount = endingVerse - startingVerse + 1
    }
}
