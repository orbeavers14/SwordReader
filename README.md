# SwordKit

[![CI](https://github.com/orbeavers14/SwordKit/actions/workflows/ci.yml/badge.svg)](https://github.com/orbeavers14/SwordKit/actions/workflows/ci.yml)

SwordKit is an experimental Swift interface to the CrossWire SWORD engine for
the Apple platform family.

It provides an idiomatic Swift API while hiding the underlying SWORD C++ implementation behind a small C-compatible bridge.

## Current features

- Swift Package Manager library
- Reproducible static SWORD build
- Thin C bridge over the SWORD C++ API
- SWORD engine and bridge version reporting
- Installed-module discovery
- Swift module metadata
- Case-insensitive module lookup

## Planned features

- Verse retrieval
- Chapter and book iteration
- Search
- Module installation and management
- iOS support

See [Docs/ROADMAP.md](Docs/ROADMAP.md) for planned milestones.

See [Docs/CONCURRENCY.md](Docs/CONCURRENCY.md) for task and actor isolation
guarantees.

See [Docs/COMPATIBILITY.md](Docs/COMPATIBILITY.md) for supported environments,
versioning, and migration policy.

See [Docs/PLATFORMS.md](Docs/PLATFORMS.md) for the macOS, iOS, iPadOS, tvOS,
visionOS, and watchOS delivery strategy.

## Requirements

- macOS 14 or later
- Swift 6
- Xcode
- CMake

## Building

Build the vendored SWORD library:

```bash
./Scripts/build-libsword.sh
