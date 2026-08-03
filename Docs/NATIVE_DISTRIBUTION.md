# Native SWORD Distribution

SwordKit wraps a C++ engine, so the Swift package must provide native SWORD code
for every supported Apple platform and architecture. It does this with a local
XCFramework exposed to Swift Package Manager as the `SwordNative` binary target.

## Why an XCFramework

An XCFramework is the standard Apple container for distributing one native
library across device and simulator destinations. This arrangement gives
SwordKit consumers a normal Swift package experience:

- no CMake installation;
- no local SWORD compilation;
- no dependency on a system-installed SWORD library;
- one tested SWORD revision across every destination; and
- reproducible linkage selected automatically by Xcode and SwiftPM.

This pattern is common for Swift packages that wrap established C or C++
libraries. The alternative—building the entire upstream project as SwiftPM
source—would expose upstream build-system details to every application build and
make feature parity across Apple SDKs harder to control.

## Repository artifact policy

`Artifacts/Sword.xcframework` is intentionally versioned with the source during
the experimental phase. Its individual libraries remain below common repository
file-size limits, but the artifact increases clone size. Once SwordKit has a
stable release process, the same XCFramework can be zipped, attached to a release,
and referenced by URL and checksum from `Package.swift`.

The local artifact keeps development deterministic until that release-hosting
workflow and its availability guarantees are automated.

## Rebuilding the artifact

Maintainers rebuild all native slices and then assemble the XCFramework:

```bash
./Scripts/build-libsword-apple.sh all
./Scripts/package-libsword-xcframework.sh
```

The build covers macOS, iOS, tvOS, visionOS, and watchOS device and simulator
destinations. The generated artifact must be reviewed and committed together with
any change to `Vendor/libsword` that affects its compiled output.

After rebuilding, run the complete Swift suite:

```bash
./Scripts/test.sh
```

Platform compilation checks should also pass before publishing a release.

## Application data is separate

The XCFramework contains the engine, not Bible modules or user study data. Host
applications remain responsible for choosing app-owned module locations,
restoration behavior, downloads, and persisted favorites, notes, or highlights.
This separation is especially important on tvOS and watchOS, where storage is
more constrained or may be purgeable.
