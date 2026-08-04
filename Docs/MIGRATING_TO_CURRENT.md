# Migrating to the Current SwordKit Architecture

Current SwordKit differs from the initial macOS-only package in four important
ways.

## Native dependency

Consumers link the bundled `Artifacts/Sword.xcframework` through Swift Package
Manager. Remove manual `libsword.a` build phases, linker search paths, and direct
desktop dependency configuration. Maintainers still use the scripts in
`Scripts/` when changing the vendored engine or rebuilding the artifact.

## Apple platforms

The package declares macOS 14, iOS/iPadOS 17, tvOS 17, visionOS 1, and watchOS
10. Application targets should meet those baselines and remove workarounds for a
macOS-only package manifest.

## Module storage

Sandboxed applications should create one `SwordModuleLocation` and use it for the
library and installer:

```swift
let location = try SwordModuleLocation.applicationSupport()
let library = try SwordLibrary(location: location)
let installerConfiguration = SwordInstallerConfiguration(location: location)
```

Applications with an existing module root should pass its explicit URLs to
`SwordModuleLocation` so content remains in place.

## Concurrency and search

`SwordLibrary` and `SwordModule` are now thread-safe `Sendable` live objects.
Native access to one module is serialized. `searchAsync` preserves structured
cancellation and executes away from the caller's actor executor.

Use `searchStream` when an `AsyncSequence` fits the consumer:

```swift
for try await result in bible.searchStream("grace") {
    print(result.reference.value)
}
```

The stream adapts SWORD's completed batch; it does not make native results
available before SWORD finishes searching.

## Validation

After migration, run `./Scripts/test.sh`, build every product destination, and
verify existing module discovery, installation, removal, refresh, rendering,
search cancellation, and app-specific restoration behavior.
