# SwordReader Roadmap

SwordReader is developed as both a launchable Bible app and an integration test
bed for public SwordKit releases. Complete and commit one milestone at a time.

## Completed

- [x] Shared observable application model
- [x] Public SwordKit 0.1.0 dependency
- [x] Adaptive iPhone, iPad, and Mac navigation shell
- [x] Chapter reading and translation selection
- [x] Cancellable Scripture search
- [x] Local SWORD catalog inspection and installation
- [x] Initial Swift Testing coverage

## Ordered milestones

1. Canonical book and chapter navigation with state restoration
2. First-launch onboarding and production module-library management
3. Accessible reading typography, rich content, footnotes, and cross references
4. Advanced search modes, scope, progress, highlighting, and recent searches
5. App-owned study-data persistence and schema migrations
6. Parallel translation and original-language comparison
7. Reading history, deep links, scene restoration, and multiple windows
8. Reading plans and optional reminders
9. Platform-specific interaction and accessibility refinement
10. Privacy, licensing, performance, localization, and release preparation

## Framework feedback loop

When an app milestone exposes a possible SwordKit issue:

1. Reproduce it directly with public SwordKit.
2. Record the SwordKit and SWORD versions, platform, module, and reference/query.
3. Add a focused regression test in SwordKit.
4. Fix and release SwordKit upstream.
5. Update the pinned SwordKit version here after the release.
