import Foundation

/// App-owned directories used for SWORD modules and installer state.
public struct SwordModuleLocation: Hashable, Sendable {
    /// The root containing `mods.d` and installed module data.
    public let modulesDirectory: URL

    /// Private storage for installer catalogs and temporary state.
    public let installerDirectory: URL

    /// Creates a location from explicit app-owned directories.
    public init(
        modulesDirectory: URL,
        installerDirectory: URL
    ) throws {
        guard modulesDirectory.isFileURL else {
            throw SwordError.invalidInstallDestination(
                modulesDirectory.absoluteString
            )
        }

        guard installerDirectory.isFileURL else {
            throw SwordError.invalidInstallerDirectory(
                installerDirectory.absoluteString
            )
        }

        self.modulesDirectory = modulesDirectory.standardizedFileURL
        self.installerDirectory = installerDirectory.standardizedFileURL
    }

    /// Creates app-specific directories beneath Application Support.
    ///
    /// This initializer only describes the locations. Directories are created
    /// when an installer writes to them.
    public init(
        applicationSupportDirectory: URL,
        applicationIdentifier: String
    ) throws {
        let identifier = applicationIdentifier.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let unsafeComponents = CharacterSet(charactersIn: "/\\")

        guard
            !identifier.isEmpty,
            identifier != ".",
            identifier != "..",
            identifier.rangeOfCharacter(from: unsafeComponents) == nil
        else {
            throw SwordError.invalidStorageIdentifier(identifier)
        }

        guard applicationSupportDirectory.isFileURL else {
            throw SwordError.invalidInstallDestination(
                applicationSupportDirectory.absoluteString
            )
        }

        let appDirectory = applicationSupportDirectory
            .standardizedFileURL
            .appending(path: identifier, directoryHint: .isDirectory)

        try self.init(
            modulesDirectory: appDirectory.appending(
                path: "Sword",
                directoryHint: .isDirectory
            ),
            installerDirectory: appDirectory.appending(
                path: "SwordInstaller",
                directoryHint: .isDirectory
            )
        )
    }

    /// Returns a sandbox-safe location beneath the user's Application Support
    /// directory.
    public static func applicationSupport(
        applicationIdentifier: String? = nil
    ) throws -> Self {
        guard let directory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw SwordError.applicationSupportDirectoryUnavailable
        }

        let identifier = applicationIdentifier
            ?? Bundle.main.bundleIdentifier
            ?? "SwordKit"

        return try Self(
            applicationSupportDirectory: directory,
            applicationIdentifier: identifier
        )
    }
}
