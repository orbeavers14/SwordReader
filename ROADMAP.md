# SwordReader Roadmap

SwordReader is developed as both a launchable Bible app and an integration test
bed for public SwordKit releases. Complete and commit one milestone at a time.

## Completed

- [x] Shared observable application model
- [x] Public SwordKit 0.4.0 dependency
- [x] Adaptive iPhone, iPad, and Mac navigation shell
- [x] Chapter reading and translation selection
- [x] Cancellable Scripture search
- [x] Local SWORD catalog inspection and installation
- [x] Initial Swift Testing coverage
- [x] Canonical book and chapter navigation with state restoration
- [x] First-launch onboarding and production module-library management
- [x] HTTPS module discovery, licensing review, progress, and cancellation
- [x] Accessible reader typography, spacing, verse-number controls, and headings
- [x] Rich attributed Scripture content, footnotes, and cross references
- [x] Advanced search modes, scope, progress, highlighting, and recent searches
- [x] App-owned study-data persistence and schema migrations
- [x] Parallel translation and original-language comparison
- [x] Reading history, deep links, scene restoration, and multiple windows
- [x] Native watchOS reading with paired module delivery, standalone downloads,
  and book/chapter navigation
- [x] Handoff continuity for reading locations across iPhone, iPad, and Mac

## Ordered milestones

1. Reading plans and optional reminders
2. Platform-specific interaction and accessibility refinement
3. Privacy, licensing, performance, localization, and release preparation

## Platform direction

- iPhone and iPad are the primary product surfaces and use native tab,
  navigation-stack, gesture, pointer, and keyboard behaviors.
- Apple Watch reads locally installed SWORD modules and supports both paired
  iPhone delivery and standalone CrossWire downloads. Its focused interface is
  Digital Crown friendly; search and heavier study tools remain on larger screens.
- macOS retains its native sidebar, commands, keyboard navigation, and windowed
  reading workspace.
- tvOS and visionOS remain later presentation targets. Shared domain values and
  service boundaries must stay UI-independent so each can adopt its own native
  focus or spatial navigation instead of inheriting a touch interface.

## Framework feedback loop

When an app milestone exposes a possible SwordKit issue:

1. Reproduce it directly with public SwordKit.
2. Record the SwordKit and SWORD versions, platform, module, and reference/query.
3. Add a focused regression test in SwordKit.
4. Fix and release SwordKit upstream.
5. Update the pinned SwordKit version here after the release.
