# Changelog

Notable changes to SwordKit are recorded here. SwordKit follows Semantic
Versioning and is currently preparing its first pre-1.0 release.

## Unreleased

No changes yet.

## 0.1.0 - 2026-08-03

### Added

- GPL-2.0-only licensing for SwordKit and explicit downstream distribution
  guidance.
- Swift-native access to installed SWORD modules, scripture content, rendering,
  navigation, reference parsing, and search.
- Cancellable asynchronous search with progress and `AsyncSequence` support.
- Parallel-passage and word-level Greek, Hebrew, and translation comparison
  values.
- Module installation, sandbox-aware storage, and immutable study-feature
  values.
- A versioned SWORD XCFramework for macOS, iOS, iPadOS, tvOS, visionOS, and
  watchOS.
- DocC tutorials, API guides, compatibility guidance, and migration guides.

### Changed

- Live library and module objects serialize access to mutable native SWORD state
  and conform to `Sendable`.

### Deferred

- Sample applications will be designed after product work identifies reusable
  UI boundaries.
