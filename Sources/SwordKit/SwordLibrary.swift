import CSwordBridge

public final class SwordLibrary {
    public init() {}

    public var bridgeVersion: String {
        guard let version = SwordBridgeVersion() else {
            return "Unknown"
        }

        return String(cString: version)
    }

    public var engineVersion: String {
        guard let version = SwordEngineVersion() else {
            return "Unknown"
        }

        return String(cString: version)
    }
}