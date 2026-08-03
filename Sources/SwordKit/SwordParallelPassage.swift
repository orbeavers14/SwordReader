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
