import CSwordBridge

public final class SwordLibrary {
    public static let bridgeVersion = string(
        from: SwordBridgeVersion()
    )

    public static let engineVersion = string(
        from: SwordEngineVersion()
    )

    public let modules: [SwordModule]

    public init() {
        guard let manager = SwordManagerCreate() else {
            modules = []
            return
        }

        defer {
            SwordManagerDestroy(manager)
        }

        let count = SwordManagerModuleCount(manager)

        modules = (0..<count).map { index in
            let name = Self.string(
                from: SwordManagerModuleName(manager, index)
            )

            let title = Self.string(
                from: SwordManagerModuleDescription(manager, index)
            )

            let language = Self.string(
                from: SwordManagerModuleLanguage(manager, index)
            )

            let type = Self.string(
                from: SwordManagerModuleType(manager, index)
            )

            return SwordModule(
                name: name,
                title: title,
                language: language,
                category: .init(swordType: type)
            )
        }
    }

    public func module(named name: String) -> SwordModule? {
        modules.first {
            $0.name.lowercased() == name.lowercased()
        }
    }

    public subscript(name: String) -> SwordModule? {
        module(named: name)
    }

    private static func string(
        from pointer: UnsafePointer<CChar>?
    ) -> String {
        guard let pointer else {
            return ""
        }

        return String(cString: pointer)
    }
}
