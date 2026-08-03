import CSwordBridge
import Foundation

/// Read-only metadata for modules available in a local SWORD repository.
public struct SwordModuleCatalogEntry: Hashable, Sendable {
    /// The module's internal SWORD identifier.
    public let name: String
    /// The human-readable module title.
    public let title: String
    /// The module's language code.
    public let language: String
    /// The general module content category.
    public let category: SwordModule.Category
    /// The published module version, when provided.
    public let version: String?
    /// Copyright information supplied by the publisher.
    public let copyright: String?
}

/// A read-only snapshot of a local SWORD repository catalog.
public struct SwordModuleCatalog: Hashable, Sendable {
    /// The standardized local repository directory.
    public let directory: URL
    /// Module metadata discovered in the repository.
    public let modules: [SwordModuleCatalogEntry]

    /// Reads a snapshot of the SWORD repository at a local directory.
    public init(directory: URL) throws {
        var isDirectory: ObjCBool = false

        guard
            directory.isFileURL,
            FileManager.default.fileExists(
                atPath: directory.path,
                isDirectory: &isDirectory
            ),
            isDirectory.boolValue
        else {
            throw SwordError.moduleCatalogNotFound(directory.absoluteString)
        }

        let handle = directory.path.withCString {
            SwordModuleCatalogCreate($0)
        }

        guard let handle else {
            throw SwordError.moduleCatalogNotFound(directory.absoluteString)
        }

        defer { SwordModuleCatalogDestroy(handle) }

        self.directory = directory.standardizedFileURL
        self.modules = (0..<SwordModuleCatalogCount(handle)).map { index in
            let type = SwordLibrary.string(
                from: SwordModuleCatalogType(handle, index)
            )

            return SwordModuleCatalogEntry(
                name: SwordLibrary.string(
                    from: SwordModuleCatalogName(handle, index)
                ),
                title: SwordLibrary.string(
                    from: SwordModuleCatalogDescription(handle, index)
                ),
                language: SwordLibrary.string(
                    from: SwordModuleCatalogLanguage(handle, index)
                ),
                category: SwordModule.Category(swordType: type),
                version: SwordLibrary.string(
                    from: SwordModuleCatalogVersion(handle, index)
                ).emptyToNil,
                copyright: SwordLibrary.string(
                    from: SwordModuleCatalogCopyright(handle, index)
                ).emptyToNil
            )
        }
    }
}

private extension String {
    var emptyToNil: String? { isEmpty ? nil : self }
}
