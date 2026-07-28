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

    public func moduleNames() -> [String] {
        guard let names = SwordInstalledModuleNames() else {
            return []
        }

        let value = String(cString: names)

        guard !value.isEmpty else {
            return []
        }

        return value
            .split(separator: "\n")
            .map(String.init)
            .sorted()
    }
}