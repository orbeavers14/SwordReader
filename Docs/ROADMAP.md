# SwordKit Roadmap

> A modern, Swift-native API for the CrossWire SWORD engine.
>
> **Vision**
>
> SwordKit aims to be the definitive Bible and biblical studies framework for
> Apple platforms, providing a clean, Swifty API while leveraging the mature
> CrossWire SWORD engine underneath.
>
> Design goals:
>
> - Swift-first API
> - Value-oriented types
> - Safe memory management
> - Modern concurrency
> - Cross-platform (macOS, iOS, iPadOS)
> - Excellent documentation
> - Stable public API

---

# Current Progress

## Core Engine

- [x] Swift Package
- [x] C++ bridge layer
- [x] Link against SWORD
- [x] Open installed modules
- [x] Module discovery
- [x] Module metadata
- [x] Safe object lifetime management

---

## Scripture Reading

- [x] Read a verse
- [x] Navigate next verse
- [x] Navigate previous verse
- [x] Retrieve passages
- [x] Retrieve chapters
- [x] Retrieve verses from reference lists

---

## Scripture Reference System

- [x] `SwordReference`
- [x] `SwordVerse`
- [x] `SwordPassage`
- [x] `SwordChapter`
- [x] `SwordReferenceList`
- [x] Native SWORD verse parsing
- [x] Expanded verse ranges
- [x] Numbered book support
- [x] Multiple disjoint passages
- [x] Cross-book passage parsing

Examples:

```swift
try bible.references(
    in: "John 3:16-18"
)

try bible.references(
    in: "John 3:16; Romans 8:28"
)

try bible.references(
    in: "John 21; Acts 1"
)
```

---

## Search

- [x] Basic phrase search
- [x] Multi-word search
- [x] Regular-expression search
- [x] Case-insensitive search
- [x] Strong's-number search
- [x] Morphology search
- [x] Scoped search
- [x] Cancellable asynchronous search
- [x] Swift-native `SwordSearchType`
- [x] Immutable `SwordSearchResult` values
- [x] SWORD relevance scores

Example:

```swift
let results = try bible.search("grace")
```

---

# Next Milestone

## Search Progress Reporting

Goal:

```swift
let results = try await bible.searchAsync(
    "faith",
    progress: { percentage in
        print(percentage)
    }
)
```

The next search milestone will expose SWORD's progress callback through a
Swift-native reporting closure.

---

# Upcoming Features

## Advanced Search

Future:

```swift
let results = try bible.search(
    "faith",
    type: .multiWord,
    caseSensitive: false,
    scope: "Romans"
)
```

Planned:

- [ ] Progress reporting
- [ ] Search result ranking

---

## Parallel Bible Support

Example:

```swift
let passage = try library.parallelPassage(
    "John 3:16-18",
    modules: [
        "KJV",
        "WEB",
        "ESV"
    ]
)
```

Planned:

- [ ] Side-by-side verses
- [ ] Missing verse detection
- [ ] Verse alignment
- [ ] Translation comparison

---

## Rich Text

- [ ] HTML rendering
- [ ] AttributedString rendering
- [ ] Strong's numbers
- [ ] Morphology
- [ ] Footnotes
- [ ] Cross references
- [ ] Headings
- [ ] Red-letter text

---

## Module Management

- [ ] Open by module name
- [ ] Filter modules
- [ ] Install modules
- [ ] Remove modules
- [ ] Refresh library
- [ ] Inspect module metadata
- [ ] Version information

---

## Study Features

- [ ] Reading plans
- [ ] Favorites
- [ ] Bookmarks
- [ ] Highlights
- [ ] Notes
- [ ] Reading history
- [ ] Saved searches
- [ ] Verse collections

---

## Maintenance

- [ ] Finalize public naming and ownership semantics
- [ ] Document every public declaration
- [ ] Establish concurrency guarantees
- [ ] Add complete integration tests
- [ ] Add continuous integration
- [ ] Publish migration and compatibility policies

---

## Concurrency

- [ ] Async APIs
- [ ] Thread-safe module access
- [ ] Background searching
- [ ] AsyncSequence support

Example:

```swift
for try await result in bible.search(
    "grace"
) {
    print(result.reference)
}
```

---

## Documentation

- [ ] DocC
- [ ] Tutorials
- [ ] Sample applications
- [ ] API guides
- [ ] Migration guides

---

# Long-Term Vision

SwordKit should become the standard Swift framework for Bible software on Apple
platforms.

Potential applications include:

- Bible readers
- Study applications
- Sermon preparation
- Devotional apps
- Reading plans
- Academic research
- Original language tools
- Parallel Bible study
- Church presentation software
- Scripture search utilities
- Bible journaling apps

---

# API Philosophy

SwordKit should always feel like modern Swift.

Good:

```swift
let verse = try bible.verse("John 3:16")
```

```swift
let chapter = try bible.chapter("Romans 8")
```

```swift
let verses = try bible.verses(
    in: "John 3; Romans 8"
)
```

```swift
let search = try bible.search("grace")
```

Not:

```swift
module.setKey(...)
module.increment()
module.renderText()
```

Those remain internal implementation details hidden behind a clean Swift API.

---

# Project Status

Current completion estimate:

Core Foundation
███████████████████████░░░░░░░░░░░░ 55%

Public Swift API
██████████████████░░░░░░░░░░░░░░░░░ 45%

Long-Term Vision
██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 15%
