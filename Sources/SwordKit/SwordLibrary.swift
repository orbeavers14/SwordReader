import CSwordBridge

public final class SwordLibrary {
    public init() {}

    public var version: String {
        guard let version = SwordBridgeVersion() else {
            return "Unknown"
        }

        return String(cString: version)
    }
}