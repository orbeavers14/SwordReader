# Developing SwordKit

SwordKit is a Swift-native wrapper around the CrossWire SWORD C++ engine. This
guide covers the repository workflow; product-facing usage belongs in the DocC
catalog and `README.md`.

## Requirements

- Xcode 26 or a compatible Swift 6.3 toolchain
- macOS 14 or later for local development
- CMake only when rebuilding vendored SWORD
- The platform SDKs needed for any Apple destinations being changed

The package supports macOS, iOS/iPadOS, tvOS, visionOS, and watchOS. The checked-in
XCFramework means an ordinary contributor does not need to compile SWORD first.

## Repository structure

```text
Sources/SwordKit       Public Swift API and DocC catalog
Sources/CSwordBridge   Thin C ABI over the SWORD C++ API
Vendor/libsword        Vendored upstream SWORD source
Artifacts              Versioned multi-platform SWORD XCFramework
Tests/SwordKitTests    Swift Testing integration and API tests
Scripts                Repeatable build, packaging, and test commands
Docs                   Architecture, platform, and maintenance policies
```

Applications depend only on the `SwordKit` product. C pointers, C++ types, and
native ownership details must not cross the public Swift boundary.

## Development workflow

Work on one roadmap milestone at a time:

1. Inspect the existing implementation and nearby tests.
2. Write or update tests first when practical.
3. Implement the smallest complete change.
4. Run `./Scripts/test.sh`.
5. Review the diff for unrelated edits.
6. Commit only after every test passes.

Tests use Swift Testing:

```swift
import Testing
```

Do not introduce XCTest cases. Integration tests intentionally use the small
module fixture managed by the existing test support.

## Running tests

```bash
./Scripts/test.sh
```

The script builds and runs the suite serially. Live `SwordLibrary` and
`SwordModule` objects synchronize native state internally, but serial test
execution also prevents independent integration tests from competing over shared
module fixtures.

## Building documentation

```bash
xcodebuild docbuild \
  -scheme SwordKit \
  -destination 'generic/platform=macOS' \
  -derivedDataPath .build/docc \
  CODE_SIGNING_ALLOWED=NO
```

Treat unresolved DocC links and documentation warnings as failures. New public
declarations require documentation and should be placed in an appropriate topic
group or guide.

## Native bridge changes

Keep `CSwordBridge` deliberately small. It should create and destroy native
objects, invoke focused SWORD operations, and return C-compatible values or
status codes. Input validation, domain modeling, concurrency APIs, persistence
guidance, and presentation behavior belong in Swift.

Every opaque native handle needs one clear owner and matching creation and
destruction functions. Copy native strings into Swift-owned values before the
underlying SWORD state changes or is destroyed.

When a bridge change alters compiled SWORD behavior, rebuild all native slices:

```bash
./Scripts/build-libsword-apple.sh all
./Scripts/package-libsword-xcframework.sh
```

Commit changes to `Vendor/libsword` and `Artifacts/Sword.xcframework` together.
Never commit intermediate output under `.build` or `Vendor/libsword/build`.

## Platform validation

The CI matrix compiles the package and tests for iOS/iPadOS, tvOS, visionOS, and
watchOS simulators in addition to running the macOS suite. Changes to the bridge,
package manifest, XCFramework, availability, or concurrency boundaries should be
validated against every supported destination before release.

Platform-neutral APIs belong in SwordKit. UI conventions, storage restoration,
background execution, and device-to-device content transfer remain the host
application's responsibility.

## Public API principles

- Prefer immutable, `Sendable` Swift values for returned data.
- Keep live native handles internal to reference types with explicit ownership.
- Translate expected bridge failures into meaningful `SwordError` values.
- Preserve structured concurrency and cancellation in asynchronous APIs.
- Avoid promising a persistence schema for study-feature values.
- Add public surface area conservatively because downstream apps will depend on
  it across every supported Apple platform.

See `ARCHITECTURE.md`, `Docs/CONCURRENCY.md`, and
`Docs/NATIVE_DISTRIBUTION.md` for the detailed design policies.

## Preparing releases

Follow `Docs/RELEASING.md` and update `CHANGELOG.md`. Do not publish a tag until
the test suite, DocC build, platform matrix, migration requirements, native
artifact review, and project-level licensing requirements are satisfied.
