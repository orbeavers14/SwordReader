import Foundation

/// A custom attributed-string key containing a normalized Strong's number.
public struct SwordStrongsNumberAttribute: AttributedStringKey {
    public typealias Value = String
    public static let name = "SwordKit.StrongsNumber"
}

/// A custom attributed-string key containing a SWORD morphology code.
public struct SwordMorphologyAttribute: AttributedStringKey {
    public typealias Value = String
    public static let name = "SwordKit.Morphology"
}

public struct SwordKitAttributes: AttributeScope {
    public let strongsNumber: SwordStrongsNumberAttribute
    public let morphology: SwordMorphologyAttribute
}

public extension AttributeScopes {
    var swordKit: SwordKitAttributes.Type { SwordKitAttributes.self }
}
