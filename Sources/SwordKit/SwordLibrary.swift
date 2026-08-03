import CSwordBridge
import Foundation

/// Provides access to the SWORD engine and its installed modules.
public final class SwordLibrary {
    /// The version of the SwordKit native bridge.
    public static let bridgeVersion = string(
        from: SwordBridgeVersion()
    )

    /// The version of the linked SWORD engine.
    public static let engineVersion = string(
        from: SwordEngineVersion()
    )

    /// The modules available through this SWORD installation.
    public let modules: [SwordModule]

    private let storage: SwordManagerStorage?

    /// Creates a library using the modules installed in the standard
    /// SWORD module locations.
    public init() {
        guard let storage = SwordManagerStorage() else {
            self.storage = nil
            self.modules = []
            return
        }

        self.storage = storage

        let count = SwordManagerModuleCount(storage.handle)

        self.modules = (0..<count).compactMap { index in
            guard let handle = SwordManagerOpenModule(
                storage.handle,
                index
            ) else {
                return nil
            }

            return SwordModule(
                storage: storage,
                handle: handle
            )
        }
    }

    /// Returns the installed module with the specified name.
    ///
    /// Module-name matching is case-insensitive.
    public func module(named name: String) -> SwordModule? {
        modules.first {
            $0.name.lowercased() == name.lowercased()
        }
    }

    /// Returns the installed module with the specified name.
    ///
    /// Module-name matching is case-insensitive.
    public subscript(name: String) -> SwordModule? {
        module(named: name)
    }

    /// Returns installed modules matching optional category and language.
    public func modules(
        category: SwordModule.Category? = nil,
        language: String? = nil
    ) -> [SwordModule] {
        modules.filter { module in
            let matchesCategory = category.map {
                module.category == $0
            } ?? true
            let matchesLanguage = language.map {
                module.language.caseInsensitiveCompare($0) == .orderedSame
            } ?? true

            return matchesCategory && matchesLanguage
        }
    }

    /// Retrieves the same Scripture range from multiple Bible modules.
    ///
    /// Passages are returned in the same order as the supplied module names.
    public func parallelPassage(
        _ reference: String,
        modules moduleNames: [String]
    ) throws -> SwordParallelPassage {
        let range = try SwordPassageRange(reference)

        let passages = try moduleNames.map { moduleName in
            guard let module = module(named: moduleName) else {
                throw SwordError.moduleNotFound(moduleName)
            }

            return try module.passage(range.value)
        }

        return SwordParallelPassage(
            reference: range,
            passages: passages
        )
    }

    internal static func string(
        from pointer: UnsafePointer<CChar>?
    ) -> String {
        guard let pointer else {
            return ""
        }

        return String(cString: pointer)
    }
}
