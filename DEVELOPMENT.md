# SwordKit Architecture

SwordKit provides a modern Swift interface to the CrossWire SWORD engine.

The package hides SWORD's C++ implementation behind a small C-compatible bridge. Applications using SwordKit interact only with Swift types and do not manage C++ objects, pointers, or native memory directly.

## Architecture overview

```text
Application
    ↓
SwordKit
    ↓
CSwordBridge
    ↓
CrossWire SWORD
```

### `SwordKit`

`SwordKit` contains the public Swift API.

Responsibilities include:

* Providing idiomatic Swift types and methods
* Validating and normalizing user input
* Converting bridge results into Swift-owned values
* Presenting errors through Swift error types
* Managing internal native handles when persistent native state is required
* Preventing C and C++ implementation details from leaking into public APIs

Examples of Swift-facing types include:

* `SwordLibrary`
* `SwordModule`
* `SwordReference`
* `SwordVerse`
* Future chapter, book, and search-result types

### `CSwordBridge`

`CSwordBridge` is the interoperability boundary between Swift and SWORD.

Responsibilities include:

* Providing a stable C ABI over the SWORD C++ API
* Creating and destroying native SWORD objects
* Performing small, direct operations supported by SWORD
* Returning primitive values, strings, opaque handles, and status codes

The bridge should remain deliberately thin.

It should not contain:

* Swift-specific behavior
* Public API design decisions
* Reference parsing that can be implemented safely in Swift
* Presentation logic
* Application-specific caching
* Business logic unrelated to native SWORD operations

### `Vendor/libsword`

`Vendor/libsword` contains the vendored CrossWire SWORD source.

The vendored source should be treated as third-party code. Changes should be avoided unless they are required for platform compatibility and cannot reasonably be handled by the build system or bridge.

Generated files under `Vendor/libsword/build` must not be committed.

### `Scripts`

The `Scripts` directory contains repeatable development commands.

* `build-libsword.sh` configures and builds the static SWORD library.
* `clean.sh` removes SwiftPM and native build products.

A contributor should not need to reconstruct CMake commands manually.

### `Tests`

Tests describe the expected behavior of the public Swift API.

Tests should generally call `SwordKit`, rather than calling `CSwordBridge` directly. Direct bridge tests may be added when native behavior cannot be verified adequately through the public API.

## Running tests

SWORD integration tests must currently run serially because the native
engine and module state are not yet guaranteed to be thread-safe.

```bash
./Scripts/test.sh

## Design principles

### Swift owns the public API

Consumers should interact with standard Swift values and familiar Swift patterns.

Public APIs should not expose:

* C pointers
* C strings
* C++ classes
* SWORD header types
* Manual native-memory operations

### The bridge remains thin

The bridge exists to make native SWORD functionality safely callable from Swift.

Whenever functionality can be implemented naturally and safely in Swift, it should usually live in the `SwordKit` target.

### Copy immutable metadata into Swift

Module metadata such as names, titles, languages, and categories should be copied into Swift-owned values.

This allows short-lived native managers to be destroyed without invalidating the resulting Swift models.

### Retain native handles only when necessary

Some operations, including passage retrieval and searching, require access to live SWORD module objects.

These objects should be represented internally by opaque bridge handles. SwordKit must own and destroy those handles automatically.

Native handles should not become part of the public API.

### Make ownership explicit

Every opaque native handle must have:

* One clearly defined creation function
* One clearly defined destruction function
* A documented owner
* Predictable behavior when creation fails

Swift wrappers that own native handles should generally be reference types so the handle is not accidentally copied.

### Copy strings before native state expires

Strings returned by SWORD may be owned by native objects or internal buffers.

SwordKit must copy such strings into Swift before:

* Destroying the corresponding native handle
* Moving to another module entry
* Changing the current SWORD key
* Performing another operation that may reuse an internal buffer

### Errors should become Swift errors

Expected failures should not be represented only by empty strings or null pointers.

The bridge may return status codes or null handles. The Swift layer should translate those results into meaningful `Error` values.

Examples include:

* Module not found
* Invalid reference
* Unsupported module type
* Passage unavailable
* Native manager creation failure

### Public types should be conservative

New public APIs should be added deliberately because removing or changing them later may break downstream applications.

Implementation details should remain internal until they are stable enough to support as public API.

### Keep features in focused commits

Native bridge changes, Swift model changes, and public behavior should be implemented in small, reviewable milestones.

Each feature should include tests before moving to the next feature.

## Current implementation

SwordKit currently supports:

* Building SWORD as a static native library
* Reporting the bridge version
* Reporting the SWORD engine version
* Discovering installed modules
* Reading module metadata
* Looking up a module by name
* Mapping SWORD module types into Swift categories

The current module metadata is copied into Swift values. The native manager is destroyed after initialization.

## Next implementation phase

The next phase introduces Scripture retrieval.

The initial scope is:

1. Open an installed module by name.
2. Retain an opaque native module session.
3. Set a textual SWORD reference.
4. Render the corresponding entry.
5. Copy the rendered text into Swift.
6. Destroy the native session automatically.

The intended API direction is:

```swift
let library = SwordLibrary()

guard let module = library.module(named: "KJV") else {
    // Handle the missing module.
    return
}

let verse = try module.verse("John 3:16")
print(verse.text)
```

The exact public API may evolve while this phase is implemented and tested.

## Roadmap

### Completed

* Reproducible native build
* Static linking
* Swift-to-C-to-C++ bridge
* Engine and bridge versions
* Installed-module discovery
* Swift module metadata model
* Module lookup

### Next: verse retrieval

* Native module-session handle
* Module opening
* Reference assignment
* Plain-text rendering
* Swift error handling
* Verse result model
* Integration tests

### Chapters and books

* Chapter retrieval
* Verse iteration
* Book enumeration
* Testament and canon metadata

### Search

* Word search
* Phrase search
* Search scopes
* Search result models
* Cancellation and progress reporting

### Module management

* Repository discovery
* Module installation
* Module updates
* Module removal
* Configuration paths

### Advanced features

* SWORD filters
* Strong's numbers and morphology
* Footnotes and cross-references
* Async APIs
* Caching
* SwiftUI-oriented helpers
