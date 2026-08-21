# SwordReader Roadmap

SwordReader is developed as both a launchable Bible app and an integration test
bed for public SwordKit releases. Complete and commit one milestone at a time.

## Completed

- [x] Shared observable application model
- [x] Public SwordKit 0.2.0 dependency
- [x] Adaptive iPhone, iPad, and Mac navigation shell
- [x] Chapter reading and translation selection
- [x] Cancellable Scripture search
- [x] Local SWORD catalog inspection and installation
- [x] Initial Swift Testing coverage
- [x] Canonical book and chapter navigation with state restoration

## Ordered milestones

1. First-launch onboarding and production module-library management
2. Accessible reading typography, rich content, footnotes, and cross references
3. Advanced search modes, scope, progress, highlighting, and recent searches
4. App-owned study-data persistence and schema migrations
5. Parallel translation and original-language comparison
6. Reading history, deep links, scene restoration, and multiple windows
7. watchOS companion reading, continuity, and compact module delivery
8. Reading plans and optional reminders
9. Platform-specific interaction and accessibility refinement
10. Privacy, licensing, performance, localization, and release preparation

## Platform direction

- iPhone and iPad are the primary product surfaces and use native tab,
  navigation-stack, gesture, pointer, and keyboard behaviors.
- Apple Watch is the next platform: recent passages, plan readings, favorites,
  and continuity should stay focused and Digital Crown friendly. The iPhone owns
  module selection and delivery policy.
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
