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
    
}
