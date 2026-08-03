import Foundation

/// A custom attributed-string key containing a normalized Strong's number.
public struct SwordStrongsNumberAttribute: AttributedStringKey {
    /// The attributed value type.
    public typealias Value = String
    /// The globally unique attributed-string key name.
    public static let name = "SwordKit.StrongsNumber"
}

/// A custom attributed-string key containing a SWORD morphology code.
public struct SwordMorphologyAttribute: AttributedStringKey {
    /// The attributed value type.
    public typealias Value = String
    /// The globally unique attributed-string key name.
    public static let name = "SwordKit.Morphology"
}

/// SwordKit's custom attributed-string keys.
public struct SwordKitAttributes: AttributeScope {
    /// The Strong's-number attribute key.
    public let strongsNumber: SwordStrongsNumberAttribute
    /// The morphology attribute key.
    public let morphology: SwordMorphologyAttribute
}

public extension AttributeScopes {
    /// SwordKit's attributed-string attribute scope.
    var swordKit: SwordKitAttributes.Type { SwordKitAttributes.self }
}
