# Migrating to Current SwordKit

Update an earlier macOS-oriented SwordKit integration to the current
multi-platform, XCFramework-backed, thread-safe API.

## Remove manual native linking

Current SwordKit includes `Artifacts/Sword.xcframework` through the private
`SwordNative` binary target. Consumer applications no longer build SWORD with
CMake or add linker search paths.

Before:

```text
Build Vendor/libsword/build/libsword.a
Add -LVendor/libsword/build -lsword
Link desktop compression and network libraries manually
```

After, add SwordKit as an ordinary package dependency and remove application
build phases that invoke `build-libsword.sh`. The native artifact selects the
correct macOS, iOS, tvOS, visionOS, or watchOS slice.

## Adopt app-owned module storage

The parameterless ``SwordLibrary/init()`` still discovers standard SWORD
locations, which is useful for traditional macOS installations. Sandboxed apps
should use one explicit ``SwordModuleLocation``.

Before:

```swift
let library = SwordLibrary()
```

After:

```swift
let location = try SwordModuleLocation.applicationSupport()
let library = try SwordLibrary(location: location)
let installer = SwordModuleInstaller(
    configuration: SwordInstallerConfiguration(location: location)
)
```

If an existing app already stores modules in a custom container, construct the
location with those existing URLs instead of moving data implicitly.

## Share live objects safely

``SwordLibrary`` and ``SwordModule`` now conform to `Sendable` and serialize
their native mutable state internally. Remove duplicate per-actor libraries that
exist only to avoid concurrent access, unless separate managers are still useful
for performance or application isolation.

Calls targeting one module wait for each other. Review workflows that start
several long searches against the same module because they are safe but execute
serially.

## Keep structured asynchronous search

`searchAsync` runs away from the caller's actor executor, reports progress, and
propagates cancellation to SWORD:

```swift
let results = try await bible.searchAsync(
    query,
    caseSensitive: false
)
```

For `AsyncSequence` consumers, migrate custom array adapters to `searchStream`:

```swift
for try await result in bible.searchStream(query) {
    consume(result)
}
```

SWORD still produces a complete native result batch before the stream yields
individual values.

## Preserve host-owned persistence

Favorites, bookmarks, highlights, notes, history, reading plans, saved searches,
and collections are immutable domain values. They are not a stable serialized
schema. Keep existing application migrations and map persisted records into the
current value initializers.

## Validate the migration

After updating:

1. Remove obsolete manual SWORD build and linker settings.
2. Confirm the app opens its existing module directory.
3. Install and remove a disposable module, refreshing afterward.
4. Exercise reading, rendering, search cancellation, and comparison.
5. Compile every Apple destination shipped by the product.
6. Verify restoration behavior on tvOS and compact content delivery on watchOS.
