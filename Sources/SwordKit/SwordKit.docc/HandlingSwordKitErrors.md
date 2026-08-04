# Handling SwordKit Errors

Translate typed framework failures into recovery choices appropriate for the
application.

## Catch typed errors

Public validation and native-operation failures use ``SwordError``:

```swift
do {
    let verse = try bible.verse(userReference)
    present(verse)
} catch SwordError.referenceNotFound(let reference) {
    showInvalidReference(reference)
} catch SwordError.moduleNotFound(let name) {
    offerModuleInstallation(name)
} catch {
    showUnexpectedError(error)
}
```

Do not present enum case names directly to users. Convert them into localized
messages and recovery actions in the product layer.

## Distinguish input from environment failures

Input errors such as ``SwordError/emptyReference``,
``SwordError/invalidPassageRange(_:)``, and
``SwordError/invalidSearchQuery(_:)`` usually call for correcting user input.

Environment errors such as ``SwordError/moduleCatalogNotFound(_:)``,
``SwordError/moduleNotFound(_:)``, or
``SwordError/applicationSupportDirectoryUnavailable`` call for installation,
storage, or restoration behavior.

Native installation and removal failures include the SWORD status code. Log the
status for diagnostics while presenting a stable application message.

## Handle cancellation separately

Asynchronous retrieval and search can throw `CancellationError`:

```swift
do {
    results = try await bible.searchAsync(query)
} catch is CancellationError {
    // A newer request replaced this one; no alert is necessary.
} catch {
    presentSearchError(error)
}
```

Cancellation is normal control flow and should rarely appear as an error alert.

## Expect file-system errors

File operations may also throw Foundation errors when a sandbox entitlement,
volume, or permission prevents access. Preserve those errors for logging and
offer a storage-specific recovery path rather than assuming every thrown value is
a ``SwordError``.
