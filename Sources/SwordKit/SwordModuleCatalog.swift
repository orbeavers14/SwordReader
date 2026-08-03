import CSwordBridge
import Foundation

/// Read-only metadata for modules available in a local SWORD repository.
public struct SwordModuleCatalogEntry: Hashable, Sendable {
    public let name: String
    public let title: String
    public let language: String
    public let category: SwordModule.Category
}

/// A read-only snapshot of a local SWORD repository catalog.
public struct SwordModuleCatalog: Hashable, Sendable {
    public let directory: URL
    public let modules: [SwordModuleCatalogEntry]

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
                category: SwordModule.Category(swordType: type)
            )
        }
    }
}
