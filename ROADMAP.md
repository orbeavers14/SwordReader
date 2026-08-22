# SwordReader Roadmap

SwordReader is developed as both a launchable Bible app and an integration test
bed for public SwordKit releases. Complete and commit one milestone at a time.

## Completed

- [x] Shared observable application model
- [x] Public SwordKit 0.5.1 dependency
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
- [x] Optional built-in reading plans, saved progress, and opt-in reminders
- [x] System-aware Dark Mode with optional appearance overrides, non-color-only
  selection states, VoiceOver traits, and native Mac keyboard navigation
- [x] App and Watch privacy manifests with documented no-collection and
  no-tracking posture
- [x] In-app privacy, open-source attribution, and installed-module licensing
  information
- [x] Bounded large-module search presentation with full result counts and
  stale-search isolation
- [x] Off-main Watch chapter decoding with cancellation and stale-load isolation
- [x] Separate English string catalogs for the shared app and Watch, with
  explicit localization for runtime labels, plans, notifications, and errors
- [x] Original app icon artwork and native iOS, iPadOS, macOS, and watchOS icon
  assets
- [x] Pre-release versioning, production bundle identity, launch metadata, and
  independent Watch companion declaration
- [x] Repeatable offline release audit and physical-device/TestFlight acceptance
  checklist
- [x] User-reviewed feature and bug reporting with privacy-safe diagnostics,
  editable GitHub issue drafts, and native Copy and Share alternatives

## Ordered milestones

1. Multiple module sources and compatibility inspection
   - Support a curated list of HTTPS SWORD repositories in addition to
     CrossWire, while keeping each source disabled until the user explicitly
     enables network access to it.
   - Add an advanced custom-source form for a repository name, HTTPS host,
     catalog path, and raw-package path; reject insecure or malformed endpoints.
   - Inspect catalogs and raw SWORD ZIP packages before installation. Show the
     source host, module identifier, category, language, version, copyright and
     distribution terms, package size when available, and compatibility result.
   - Initially accept Bible-category modules with readable SWORD configuration
     and content supported by the pinned SwordKit/SWORD release. Clearly reject
     unsupported module categories, unsafe archives, missing metadata, duplicate
     identifiers, and formats that are not packaged as SWORD modules.
   - Keep local document-picker import for offline SWORD repositories and add a
     reviewed raw-ZIP import path when SwordKit can provide the same validation
     report used for remote sources.
   - Persist only sources the user approves, provide source removal and catalog
     refresh controls, and preserve publisher licensing boundaries.

2. System-adaptive layered app icon
   - Rebuild the current book-and-sword mark as editable layers in Apple Icon
     Composer rather than relying only on flattened PNG artwork.
   - Tune and preview Default, Dark, Clear Light, Clear Dark, Tinted Light, and
     Tinted Dark appearances on iPhone, iPad, and Mac while keeping the same
     recognizable silhouette in every appearance.
   - Provide the native layered watchOS rendering, recognizing that watchOS does
     not currently expose the appearance variants available on iOS and macOS.
   - Verify legibility and contrast at every system-generated size, on varied
     wallpapers, with system tint colors, and with Increase Contrast enabled.
   - Retain the current asset-catalog icons as compatibility fallbacks until the
     minimum supported OS and Xcode release make the Icon Composer asset safe to
     adopt exclusively.

3. Launch coordination
   - Complete Apple Developer signing, physical-device testing, App Store
     records, screenshots, support and privacy-policy URLs, and beta feedback.

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
