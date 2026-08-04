# Searching Scripture

Use synchronous, array-returning async, or streaming search APIs with the same
matching options.

## Choose a search type

The default phrase search matches exact word sequences. SwordKit also supports
multi-word, regular-expression, Strong's-number, and morphology searches through
``SwordSearchType``.

```swift
let results = try bible.search(
    "grace",
    caseSensitive: false,
    scope: "Romans"
)
```

Every ``SwordSearchResult`` contains an immutable reference, module name,
rendered text, and SWORD relevance score.

## Search asynchronously

`searchAsync` runs native search work away from the caller's actor executor and
supports task cancellation and progress reporting:

```swift
let results = try await bible.searchAsync(
    "faith hope love",
    type: .multiWord,
    caseSensitive: false,
    progress: { percentage in
        print("\(percentage)%")
    }
)
```

The module serializes native access, so other operations using that same module
wait safely while its search is active.

## Stream results

Use `searchStream` when a consumer naturally processes an `AsyncSequence`:

```swift
for try await result in bible.searchStream("grace") {
    print(result.reference.value)
}
```

SWORD completes its native batch search before results become available. The
stream then yields each result cooperatively in SWORD order. Ending iteration
cancels the producing task and signals an active search to terminate.
