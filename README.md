# SwordKit

[![CI](https://github.com/orbeavers14/SwordKit/actions/workflows/ci.yml/badge.svg)](https://github.com/orbeavers14/SwordKit/actions/workflows/ci.yml)

SwordKit is an experimental Swift interface to the CrossWire SWORD engine for
the Apple platform family.

It provides an idiomatic Swift API while hiding the underlying SWORD C++ implementation behind a small C-compatible bridge.

## Current features

- Swift Package Manager library
- Versioned multi-platform SWORD XCFramework
- Thin C bridge over the SWORD C++ API
- Installed-module discovery
- Verse, passage, chapter, and reference-list retrieval
- Phrase, regular-expression, Strong's-number, and morphology search
- Translation and word-level language comparison values
- Module installation and study-feature values
- macOS, iOS, iPadOS, tvOS, visionOS, and watchOS package support

See [Docs/ROADMAP.md](Docs/ROADMAP.md) for planned milestones.

See [Docs/CONCURRENCY.md](Docs/CONCURRENCY.md) for task and actor isolation
guarantees.

See [Docs/COMPATIBILITY.md](Docs/COMPATIBILITY.md) for supported environments,
versioning, and migration policy.

See [Docs/MIGRATING_TO_CURRENT.md](Docs/MIGRATING_TO_CURRENT.md) when updating an
earlier macOS-oriented or manually linked integration.

See [Docs/PLATFORMS.md](Docs/PLATFORMS.md) for the macOS, iOS, iPadOS, tvOS,
visionOS, and watchOS delivery strategy.

See [Docs/NATIVE_DISTRIBUTION.md](Docs/NATIVE_DISTRIBUTION.md) for why SwordKit
ships a native XCFramework and how it is maintained.

Open the SwordKit product documentation in Xcode for DocC guides covering setup,
Apple-platform storage, search, translation comparison, and migration.

## Requirements

- macOS 14, iOS/iPadOS 17, tvOS 17, visionOS 1, or watchOS 10
- Swift 6.3 or later
- Xcode 26 or a compatible Swift toolchain

CMake is required only when rebuilding the bundled SWORD artifact.

## Building

Consumers build SwordKit normally; the versioned XCFramework is already included:

```bash
swift build
```

Maintainers can rebuild a platform-specific native slice under
`.build/sword-apple`:

```bash
./Scripts/build-libsword-apple.sh ios-simulator
```

Use `all` to rebuild every supported Apple destination.

Package completed slices into an XCFramework:

```bash
./Scripts/package-libsword-xcframework.sh
```

## App-owned module storage

Use the sandbox-aware Application Support location for ordinary applications:

```swift
let location = try SwordModuleLocation.applicationSupport()
let library = try SwordLibrary(location: location)
let installerConfiguration = SwordInstallerConfiguration(location: location)
```

Apps with shared containers or platform-specific restoration policies can create
`SwordModuleLocation` from explicit module and installer directory URLs instead.

## Streaming search

Search results can also be consumed as a cancellable asynchronous sequence:

```swift
for try await result in bible.searchStream("grace") {
    print(result.reference.value)
}
```
