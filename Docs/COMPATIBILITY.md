# Compatibility and Migration Policy

SwordKit is currently an experimental pre-1.0 package. This policy describes
how releases communicate compatibility while the public API matures.

## Versioning

SwordKit follows Semantic Versioning.

- Before 1.0, a minor release may contain source-breaking public API changes.
- Patch releases preserve source compatibility and contain fixes or compatible
  additions.
- Beginning with 1.0, source-breaking public API changes require a new major
  version.

Every source-breaking release must identify affected declarations and provide
replacement examples in release notes or a versioned migration guide.

## Supported environments

The package manifest is the authoritative compatibility declaration. The current
baseline is:

- macOS 14 or later
- iOS and iPadOS 17 or later
- tvOS 17 or later
- visionOS 1 or later
- watchOS 10 or later
- Swift 6.3 or later
- Xcode 26 or a compatible Swift toolchain
- The vendored CrossWire SWORD source included in this repository

The package manifest and bundled XCFramework declare all of these platforms.
Automated platform compilation and runtime integration coverage remain release
gates while SwordKit is experimental. On watchOS, compact local module sets and
paired-iPhone content delivery are recommended even though the full framework
compiles for the platform.

Support for an older platform or toolchain may be removed in a minor release
before 1.0. After 1.0, raising a platform or toolchain minimum requires advance
notice in release notes and follows the package's major-version compatibility
policy when it breaks supported clients.

## Public API changes

Compatible additions may ship in minor releases. Renames and replacements should
use Swift availability deprecations when the old API can be maintained safely.
After 1.0, deprecated APIs remain available for at least one minor release before
removal in the next major release.

Immediate removal is reserved for APIs that cannot be retained safely, such as a
boundary that violates memory safety or corrupts native SWORD state. The release
notes must explain the exception and the required migration.

## Native SWORD compatibility

SwordKit links the versioned `Artifacts/Sword.xcframework`, built from the SWORD
revision in `Vendor/libsword`. System-installed SWORD libraries are not part of
the supported binary contract. Updates to either the source or artifact must be
made together, pass the complete bridge and Swift test suite, and call out
observable rendering, search, or module-format changes.

SWORD module data remains external user content. SwordKit does not promise that
every third-party module is valid, but supported releases preserve access to
module formats handled by the vendored engine unless release notes state
otherwise.

## Persisted application data

Study-feature types are immutable domain values, not a persistence format.
Applications own serialization and schema migration for favorites, notes,
highlights, reading history, saved searches, and verse collections. Adding
`Codable` conformance in the future will require an explicitly documented schema
and migration policy before it is treated as stable storage.

## Migration guides

A migration guide is required when a release changes public names, argument
labels, result types, concurrency isolation, platform minimums, or persisted
schemas. Each guide should include:

1. The previous API or behavior.
2. The replacement API or behavior.
3. A minimal before-and-after example.
4. Any data, threading, or deployment consequences.

Use the [migration guide template](MIGRATION_GUIDE_TEMPLATE.md) for future
breaking releases. Applications adopting the current architecture should start
with [Migrating to the Current SwordKit Architecture](MIGRATING_TO_CURRENT.md).
