/// Errors produced by SwordKit operations.
public enum SwordError: Error, Equatable, Sendable {
    /// A reference contained no non-whitespace characters.
    case emptyReference

    /// The requested operation is not supported by this module type.
    case unsupportedModuleType

    /// The SWORD engine could not position the module at the reference.
    case referenceNotFound(String)

    /// SWORD returned no normalized reference after positioning.
    case missingResolvedReference

    /// SWORD returned no rendered content for the requested reference.
    case emptyRenderedText(reference: String)
    
    case invalidVerseCount(Int)
    
    /// The supplied passage range could not be interpreted.
    case invalidPassageRange(String)

    /// The ending verse precedes the starting verse.
    case reversedPassageRange(String)
    
    /// The supplied chapter reference could not be interpreted.
    case invalidChapterReference(String)
    
    case invalidReferenceList(String)

    /// A search query contained no non-whitespace characters.
    case invalidSearchQuery(String)

    /// A Strong's number was not a `G` or `H` followed by digits.
    case invalidStrongsNumber(String)

    /// No installed module matched the requested name.
    case moduleNotFound(String)

    /// An installer destination was not a local file URL.
    case invalidInstallDestination(String)

    /// Installer-private storage was not a local file URL.
    case invalidInstallerDirectory(String)

    /// A module repository omitted a required identity or host value.
    case invalidModuleRepository(String)

    /// No local SWORD repository existed at the supplied directory.
    case moduleCatalogNotFound(String)

    /// SWORD could not install a selected module.
    case moduleInstallationFailed(module: String, status: Int32)
    
}
