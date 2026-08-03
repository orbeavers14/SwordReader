# Apple Platform Strategy

SwordKit is designed for the Apple ecosystem. Platform support becomes official
only when the package manifest, native SWORD artifacts, automated builds, and
platform integration tests all cover that destination.

## Intended platform family

| Platform | Intended baseline | Product direction |
| --- | --- | --- |
| macOS | macOS 14 | Full framework, local modules, installation, search, and study tools |
| iOS and iPadOS | iOS 17 | Full framework with sandbox-aware module storage and installation |
| tvOS | tvOS 17 | Reading, search, comparison, and app-managed module storage |
| visionOS | visionOS 1 | Full reading and study framework with app-managed module storage |
| watchOS | watchOS 10 | Companion-first values and reading features; full native engine subject to validation |

These baselines align the first cross-platform release around the same generation
of Foundation, Swift concurrency, and attributed-string APIs. They remain planned
minimums until declared in `Package.swift` and verified in continuous integration.

## Portable today

The following layers are Swift-native and already suitable for every intended
platform:

- Scripture reference, verse, passage, chapter, and search-result values
- Translation and word-level comparison values
- Reading plans, favorites, bookmarks, notes, highlights, and collections
- `Sendable` result boundaries and cancellable async APIs
- Foundation-based attributed-string attributes

The public API hides raw C++ pointers, so clients do not need platform-specific
SWORD integration code.

## Native build requirement

The current `libsword.a` is built for macOS only. Apple-family support requires
reproducible static SWORD slices for device and simulator SDKs, packaged as an
XCFramework or an equivalent Swift Package Manager artifact.

The native build must cover:

- macOS
- iOS and iOS Simulator
- tvOS and tvOS Simulator
- visionOS and visionOS Simulator
- watchOS and watchOS Simulator before full watchOS engine support is promised

Each slice must use the same vendored SWORD revision and compatible feature
flags. The C bridge must compile against every supported SDK without importing UI
frameworks.

## Storage and installation

SWORD module discovery cannot assume traditional desktop paths outside macOS.
Sandboxed apps must supply an app-owned module directory.

- iOS, iPadOS, and visionOS should use Application Support for durable modules.
- tvOS must tolerate system-purgeable local storage and support restoration.
- watchOS should normally receive compact, app-selected content from its paired
  iPhone unless full on-watch module storage proves practical.
- Remote installation must remain explicitly configured by the host app.

## Rendering

SwordKit's plain text, HTML, and Swift `AttributedString` results remain the
cross-platform rendering boundary. AppKit and UIKit conversions are conveniences,
not requirements for the core engine. SwiftUI applications should consume the
portable values directly whenever possible.

## Delivery sequence

1. Produce and validate multi-SDK native SWORD artifacts.
2. Replace the macOS-only linker path with platform-aware package integration.
3. Add iOS, tvOS, visionOS, and conditional watchOS declarations to
   `Package.swift`.
4. Add compile and integration jobs for device/simulator SDKs.
5. Validate sandbox storage and module restoration on each platform.
6. Publish support only after all required checks pass.
