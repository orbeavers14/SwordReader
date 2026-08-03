/// A passage retrieved from multiple Bible modules in caller-supplied order.
public struct SwordParallelPassage: Hashable, Sendable {
    /// The requested Scripture range.
    public let reference: SwordPassageRange

    /// One passage for each requested Bible module.
    public let passages: [SwordPassage]

    public init(
        reference: SwordPassageRange,
        passages: [SwordPassage]
    ) {
        self.reference = reference
        self.passages = passages
    }
}
