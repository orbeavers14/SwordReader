# SwordReader

[![Apple platform builds](https://github.com/orbeavers14/SwordReader/actions/workflows/ci.yml/badge.svg)](https://github.com/orbeavers14/SwordReader/actions/workflows/ci.yml)
[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](LICENSE)

SwordReader is a multiplatform SwiftUI Bible reader for iOS, iPadOS, and macOS.
It consumes the public `SwordKit` 0.4.0 package and keeps SWORD modules in the
application's Application Support container.

## Open and run

Open `SwordReader.xcodeproj` in Xcode 26 or later. Choose `SwordReader` for iOS
and iPadOS, or `SwordReader-macOS` for macOS.

SwordKit does not bundle or implicitly download Bible modules. Use **Library →
Get Bibles** to review the privacy notice, browse and search the CrossWire Bible
Society catalog over HTTPS, and download a translation. Download progress can be
cancelled, and publisher-supplied licensing metadata is shown before installation.
**Import Local Catalog** remains available as an advanced offline option for a
SWORD repository containing a `mods.d` directory. Swipe an
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
- App preferences and reading position use `UserDefaults`, which participates in
  normal encrypted device backups; SwordReader does not require an account or server.
- Reader appearance uses semantic Dynamic Type styles with persisted system,
  serif, or rounded design, text-size, spacing, and verse-number choices.
- Publisher-supplied Scripture headings are rendered as accessible headings in
  the native reading flow.
- Supported module markup is rendered as native attributed text with a
  plain-text fallback. Verse notes and parsed cross-references open in a native
  sheet, and Scripture references navigate through the shared reader model.
- Search supports phrase, all-word, regular-expression, Strong’s-number, and
  morphology matching across the whole Bible or either testament. Results are
  ranked, matched text is emphasized, progress is visible, and recent searches
  remain on-device.
- Bookmarks and personal verse notes are stored separately from Bible modules in
  a versioned SwiftData schema with an explicit migration plan. Removing or
  updating a module does not silently delete the app-owned study records.

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
