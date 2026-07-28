# SwordKit Development Guide

SwordKit is a Swift package that provides a modern Swift interface to the CrossWire SWORD C++ library.

The project uses a small C-compatible bridge between Swift and SWORD:

```text
Swift
  ↓
CSwordBridge
  ↓
C++
  ↓
libsword
```

## Requirements

SwordKit development currently requires:

* macOS
* Xcode and the Xcode command-line tools
* Swift Package Manager
* CMake
* A local copy of the SWORD source in `Vendor/libsword`

Install CMake with Homebrew if necessary:

```bash
brew install cmake
```

Verify the required tools:

```bash
swift --version
cmake --version
clang --version
```

## Project structure

```text
SwordKit/
├── Package.swift
├── DEVELOPMENT.md
├── Scripts/
│   ├── build-libsword.sh
│   └── clean.sh
├── Sources/
│   ├── CSwordBridge/
│   │   ├── include/
│   │   │   └── sword_bridge.h
│   │   └── sword_bridge.cpp
│   └── SwordKit/
├── Tests/
│   └── SwordKitTests/
└── Vendor/
    └── libsword/
```

## Building SWORD

Before building or testing SwordKit, build the vendored SWORD static library:

```bash
./Scripts/build-libsword.sh
```

The script:

1. Creates a clean SWORD build directory.
2. Configures SWORD with CMake.
3. Sets the minimum macOS deployment target to macOS 14.
4. enables compatibility with SWORD's older CMake configuration.
5. Builds only the static `sword_static` target.
6. Verifies that `Vendor/libsword/build/libsword.a` exists.

The generated native library is located at:

```text
Vendor/libsword/build/libsword.a
```

The build directory is generated locally and should not be committed to Git.

## Running the tests

After building SWORD, run:

```bash
swift test
```

A complete clean build can be performed with:

```bash
./Scripts/clean.sh
./Scripts/build-libsword.sh
swift test
```

## Cleaning the project

Run:

```bash
./Scripts/clean.sh
```

This removes:

```text
.build/
Vendor/libsword/build/
```

It does not remove the SWORD source or any SwordKit source files.

## Custom build settings

The SWORD build script defaults to:

```text
Build type: Release
macOS deployment target: 14.0
```

The values can be overridden through environment variables.

For example:

```bash
BUILD_TYPE=Debug ./Scripts/build-libsword.sh
```

Or:

```bash
MACOS_DEPLOYMENT_TARGET=15.0 ./Scripts/build-libsword.sh
```

The package's declared platform version and the native library deployment target should remain compatible.

## Native dependencies

The current SWORD configuration uses the following macOS system libraries:

* zlib
* bzip2
* liblzma
* libcurl

These dependencies are declared in `Package.swift` using SwiftPM linker settings.

SWORD itself is linked statically through:

```text
Vendor/libsword/build/libsword.a
```

Only the static SWORD library should be present in the build directory. If a dynamic `libsword` library is present, the linker may prefer it and the test bundle may fail at runtime because the library is not embedded.

## Common problems

### CMake compatibility error

Newer versions of CMake may report:

```text
Compatibility with CMake < 3.5 has been removed
```

The build script handles this by passing:

```text
-DCMAKE_POLICY_VERSION_MINIMUM=3.5
```

### Test bundle cannot load libsword

An error similar to the following means the executable was linked against a dynamic SWORD library:

```text
Library not loaded: @rpath/libsword...dylib
```

Clean and rebuild using the project scripts:

```bash
./Scripts/clean.sh
./Scripts/build-libsword.sh
swift test
```

The build script compiles only the static SWORD target.

### Undefined compression symbols

Errors involving functions such as these indicate missing native linker dependencies:

```text
compress2
BZ2_bzBuffToBuffCompress
lzma_stream_buffer_decode
```

Confirm that `Package.swift` links:

```swift
.linkedLibrary("z")
.linkedLibrary("bz2")
.linkedLibrary("lzma")
.linkedLibrary("curl")
```

### Old-source compiler warnings

SWORD may produce warnings involving:

* deprecated C functions such as `sprintf`
* invalid or legacy source encodings
* old CMake compatibility policies

These warnings originate in the vendored SWORD code. They do not necessarily indicate that the SwordKit bridge or build has failed.

Always check the final lines of the build output to determine whether the library was created successfully.

## Development workflow

A normal development session should use:

```bash
swift test
```

Rebuild SWORD when:

* the vendored SWORD source changes;
* SWORD build settings change;
* the macOS deployment target changes;
* the static library is missing;
* native linker behavior changes.

Use:

```bash
./Scripts/build-libsword.sh
swift test
```

Before committing major native-build changes, verify a complete clean build:

```bash
./Scripts/clean.sh
./Scripts/build-libsword.sh
swift test
```
