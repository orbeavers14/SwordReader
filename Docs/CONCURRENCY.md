# Concurrency

SwordKit separates portable Swift values from live SWORD engine objects.

## Portable values

Retrieved content, references, search results, comparison values, installer
configuration, and study-feature models conform to `Sendable`. They are immutable
snapshots and may be passed between tasks and actors.

This includes values such as `SwordVerse`, `SwordPassage`,
`SwordSearchResult`, `SwordVerseComparison`, and `SwordNote`.

## Live engine objects

`SwordLibrary` and `SwordModule` do not conform to `Sendable`. They own mutable
native SWORD manager and module handles, including cursor and search state. Keep
each library and its modules within the task or actor that owns them. Do not pass
these objects between actors or invoke the same module concurrently.

Create a separate `SwordLibrary` inside another actor when that actor needs live
SWORD access. Pass the resulting immutable SwordKit values back across the actor
boundary.

## Asynchronous search

`SwordModule.searchAsync` supports Swift task cancellation and accepts an
`@Sendable` progress callback. It remains an operation on the module's owning
executor; it does not make the live module safe for concurrent use.

Cancellation may signal the native search from Swift's cancellation handler.
Callers should handle `CancellationError` in the same way as other cancellable
Swift APIs.

## Future thread-safe access

Thread-safe shared module access is a separate roadmap feature. Until that work
is complete, SwordKit will not use `@unchecked Sendable` to imply safety for live
native objects.
