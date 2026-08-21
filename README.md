# SwordReader

[![Apple platform builds](https://github.com/orbeavers14/SwordReader/actions/workflows/ci.yml/badge.svg)](https://github.com/orbeavers14/SwordReader/actions/workflows/ci.yml)
[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)

SwordReader is a multiplatform SwiftUI Bible reader for iOS, iPadOS, and macOS.
It consumes the public `SwordKit` 0.2.0 package and keeps SWORD modules in the
application's Application Support container.

## Open and run

Open `SwordReader.xcodeproj` in Xcode 26 or later. Choose `SwordReader` for iOS
and iPadOS, or `SwordReader-macOS` for macOS.

SwordKit does not bundle or implicitly download Bible modules. Use **Library →
Import Local Catalog** to select a local SWORD repository containing a `mods.d`
directory, then install a Bible from that catalog. The Library shows module
version and licensing metadata when supplied by the publisher. Swipe an
installed Bible on iPhone or iPad, or use its context menu on any platform, to
remove it after confirmation.

## Architecture

- `AppModel` is the shared, main-actor application model.
- `SwordScriptureService` is the sole SwordKit integration boundary and keeps
  live library/module objects out of views.
- Immutable app snapshots cross from the service into SwiftUI.
- Compact layouts use a native tab-based hierarchy; iPad and macOS use a
  `NavigationSplitView` workspace.
- Platform-specific commands and toolbar placement stay in platform files.

## Verify

```sh
xcodebuild test \
  -project SwordReader.xcodeproj \
  -scheme SwordReader-macOS \
  -destination 'platform=macOS'
```

CI also builds the generic iOS destination to validate iPhone and iPad support.

## Development policy

SwordReader is both a potential shipping application and the reference consumer
for public SwordKit releases. It must depend on a tagged public SwordKit version,
not a modified local copy.

Reproduce framework problems in SwordKit and fix them upstream. After a tagged
SwordKit release contains the correction, update SwordReader's pinned dependency.
Application behavior, persistence, navigation, and presentation remain here.

See [ROADMAP.md](ROADMAP.md) for the ordered product milestones.
