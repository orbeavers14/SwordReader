# Concurrency

SwordKit separates portable Swift values from live SWORD engine objects.

## Portable values

Retrieved content, references, search results, comparison values, installer
configuration, and study-feature models conform to `Sendable`. They are immutable
snapshots and may be passed between tasks and actors.

This includes values such as `SwordVerse`, `SwordPassage`,
`SwordSearchResult`, `SwordVerseComparison`, and `SwordNote`.

## Live engine objects

`SwordLibrary` and `SwordModule` conform to `Sendable` using internal recursive
locks around their mutable native SWORD manager, cursor, parsing, rendering, and
search state. A library or module may be shared between tasks and actors. Calls
on the same live module are serialized; separate modules can continue working
independently.

Returned values remain immutable snapshots and do not retain mutable cursor or
search-result state.

## Asynchronous search

`SwordModule.searchAsync` supports Swift task cancellation and accepts an
`@Sendable` progress callback. Other operations targeting the same module wait
until the active search releases its serialized native access.

Cancellation may signal the native search from Swift's cancellation handler.
Callers should handle `CancellationError` in the same way as other cancellable
Swift APIs.

## Asynchronous retrieval

`SwordModule.versesAsync(in:)` and
`SwordLibrary.parallelPassageAsync(_:modules:)` preserve input order and check
for cancellation between native retrieval operations. They may be called from
any concurrency domain; operations sharing a module are serialized internally.
