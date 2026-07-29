/// An immutable collection of Scripture references.
public struct SwordReferenceList:
    RandomAccessCollection,
    Hashable,
    Sendable
{
    public typealias Element = SwordReference
    public typealias Index = Int

    /// The references contained in the list.
    public let references: [SwordReference]

    public var startIndex: Int {
        references.startIndex
    }

    public var endIndex: Int {
        references.endIndex
    }

    public subscript(position: Int) -> SwordReference {
        references[position]
    }

    public func index(after index: Int) -> Int {
        references.index(after: index)
    }

    public func index(before index: Int) -> Int {
        references.index(before: index)
    }

    public init(references: [SwordReference]) {
        self.references = references
    }
}
