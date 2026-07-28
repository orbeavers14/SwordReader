import Foundation

/// A textual reference to a location in a SWORD module.
///
/// Examples include `"John 3:16"`, `"Mark 1:11"`, and
/// `"Genesis 1:1"`.
public struct SwordReference:
    Hashable,
    Sendable,
    CustomStringConvertible
{
    /// The reference supplied to or normalized by the SWORD engine.
    public let value: String

    /// Creates a Scripture reference.
    ///
    /// - Parameter value: A nonempty reference such as `"John 3:16"`.
    /// - Throws: ``SwordError/emptyReference`` when the value contains
    ///   no non-whitespace characters.
    public init(_ value: String) throws {
        let normalized = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !normalized.isEmpty else {
            throw SwordError.emptyReference
        }

        self.value = normalized
    }

    /// The textual value of the reference.
    public var description: String {
        value
    }
}
