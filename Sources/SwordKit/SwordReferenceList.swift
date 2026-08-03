/// An immutable collection of Scripture references.
public struct SwordReferenceList:
    RandomAccessCollection,
    Hashable,
    Sendable
{
    /// The collection element type.
    public typealias Element = SwordReference
    /// The collection index type.
    public typealias Index = Int

    /// The references contained in the list.
    public let references: [SwordReference]

    /// The position of the first reference.
    public var startIndex: Int {
        references.startIndex
    }

    /// The position one past the final reference.
    public var endIndex: Int {
        references.endIndex
    }

    /// Returns the reference at the specified position.
    public subscript(position: Int) -> SwordReference {
        references[position]
    }

    /// Returns the position immediately after an index.
    public func index(after index: Int) -> Int {
        references.index(after: index)
    }

    /// Returns the position immediately before an index.
    public func index(before index: Int) -> Int {
        references.index(before: index)
    }

    /// Creates a reference list preserving the supplied order.
    public init(references: [SwordReference]) {
        self.references = references
    }
}
