import Foundation

/// Immutable configuration for module installation operations.
public struct SwordInstallerConfiguration: Hashable, Sendable {
    /// The SWORD library root that receives installed modules.
    public let destinationDirectory: URL

    /// Private storage for installer configuration and repository catalogs.
    public let privateDirectory: URL

    /// Remote repositories available to an explicitly created installer.
    public let repositories: [SwordModuleRepository]

    public init(
        destinationDirectory: URL,
        privateDirectory: URL,
        repositories: [SwordModuleRepository] = []
    ) throws {
        guard destinationDirectory.isFileURL else {
            throw SwordError.invalidInstallDestination(
                destinationDirectory.absoluteString
            )
        }

        guard privateDirectory.isFileURL else {
            throw SwordError.invalidInstallerDirectory(
                privateDirectory.absoluteString
            )
        }

        self.destinationDirectory = destinationDirectory.standardizedFileURL
        self.privateDirectory = privateDirectory.standardizedFileURL
        self.repositories = repositories
    }
}

/// A remote SWORD module repository.
public struct SwordModuleRepository: Hashable, Sendable {
    public enum Transport: String, Hashable, Sendable {
        case http = "HTTP"
        case https = "HTTPS"
        case ftp = "FTP"
    }

    public let identifier: String
    public let name: String
    public let transport: Transport
    public let host: String
    public let directory: String

    public init(
        identifier: String,
        name: String,
        transport: Transport,
        host: String,
        directory: String
    ) throws {
        let identifier = identifier.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let host = host.trimmingCharacters(in: .whitespacesAndNewlines)
        let directory = directory.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !identifier.isEmpty, !name.isEmpty, !host.isEmpty else {
            throw SwordError.invalidModuleRepository(identifier)
        }

        self.identifier = identifier
        self.name = name
        self.transport = transport
        self.host = host
        self.directory = directory
    }
}
