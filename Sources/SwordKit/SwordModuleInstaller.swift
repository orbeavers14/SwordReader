import CSwordBridge
import Foundation

/// Performs explicit SWORD module installation operations.
public struct SwordModuleInstaller: Sendable {
    /// The destinations and repositories used by this installer.
    public let configuration: SwordInstallerConfiguration

    /// Creates an installer with explicit configuration.
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

    /// Removes one module from the configured destination.
    public func remove(moduleNamed moduleName: String) throws {
        let catalog = try SwordModuleCatalog(
            directory: configuration.destinationDirectory
        )

        guard catalog.modules.contains(where: { $0.name == moduleName }) else {
            throw SwordError.moduleNotFound(moduleName)
        }

        let status = configuration.privateDirectory.path.withCString {
            privatePath in
            configuration.destinationDirectory.path.withCString {
                destinationPath in
                moduleName.withCString { name in
                    SwordRemoveModule(privatePath, destinationPath, name)
                }
            }
        }

        guard status == 0 else {
            throw SwordError.moduleRemovalFailed(
                module: moduleName,
                status: status
            )
        }
    }
}
