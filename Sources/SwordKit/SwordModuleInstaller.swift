import CSwordBridge
import Foundation

/// Performs explicit SWORD module installation operations.
public struct SwordModuleInstaller: Sendable {
    public let configuration: SwordInstallerConfiguration

    public init(configuration: SwordInstallerConfiguration) {
        self.configuration = configuration
    }

    /// Installs one module from a local repository catalog.
    public func install(
        moduleNamed moduleName: String,
        from catalog: SwordModuleCatalog
    ) throws {
        guard catalog.modules.contains(where: { $0.name == moduleName }) else {
            throw SwordError.moduleNotFound(moduleName)
        }

        let fileManager = FileManager.default
        try fileManager.createDirectory(
            at: configuration.destinationDirectory,
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: configuration.destinationDirectory.appending(
                path: "mods.d",
                directoryHint: .isDirectory
            ),
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(
            at: configuration.privateDirectory,
            withIntermediateDirectories: true
        )

        let status = configuration.privateDirectory.path.withCString {
            privatePath in
            configuration.destinationDirectory.path.withCString {
                destinationPath in
                catalog.directory.path.withCString { sourcePath in
                    moduleName.withCString { name in
                        SwordInstallLocalModule(
                            privatePath,
                            destinationPath,
                            sourcePath,
                            name
                        )
                    }
                }
            }
        }

        guard status == 0 else {
            throw SwordError.moduleInstallationFailed(
                module: moduleName,
                status: status
            )
        }
    }
}
