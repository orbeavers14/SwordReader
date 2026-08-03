import Foundation

/// A custom attributed-string key containing a normalized Strong's number.
public struct SwordStrongsNumberAttribute: AttributedStringKey {
    public typealias Value = String
    public static let name = "SwordKit.StrongsNumber"
}

public struct SwordKitAttributes: AttributeScope {
    public let strongsNumber: SwordStrongsNumberAttribute
}

public extension AttributeScopes {
    var swordKit: SwordKitAttributes.Type { SwordKitAttributes.self }
}
