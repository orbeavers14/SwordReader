/// A verse retrieved from a biblical SWORD module.
public struct SwordVerse: Hashable, Sendable {
    /// The reference as resolved by the SWORD engine.
    public let reference: SwordReference

    /// The module identifier from which the verse was retrieved.
    public let moduleName: String

    /// The rendered verse content returned by SWORD.
    public let text: String

    /// Creates a retrieved verse value.
    public init(
        reference: SwordReference,
        moduleName: String,
        text: String
    ) {
        self.reference = reference
        self.moduleName = moduleName
        self.text = text
    }
}
