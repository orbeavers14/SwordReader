# Comparing Translations and Languages

Align the same Scripture range across translations, then inspect differences at
the verse and word levels.

## Retrieve a parallel passage

Request modules in the order the application wants to present them:

```swift
let parallel = try library.parallelPassage(
    "John 3:16-18",
    modules: ["KJV", "WEB"]
)
```

``SwordParallelPassage/passages`` preserves module order, while
``SwordParallelPassage/missingReferences`` identifies verses absent from a
translation.

## Align verses

``SwordParallelPassage/alignedVerses`` groups available verses by canonical
reference. Each ``SwordAlignedVerse`` exposes its source verses and a
``SwordVerseComparison`` value:

```swift
for alignedVerse in parallel.alignedVerses {
    let comparison = alignedVerse.comparison
    print(comparison.reference.value, comparison.hasTextDifferences)
}
```

## Compare words

Word comparison retains display text while providing normalized text, lemma,
morphology, and Strong's-number information when the modules contain it:

```swift
let comparison = parallel.alignedVerses[0].comparison

for link in comparison.wordLinks {
    print(link.strongsNumber, link.locations)
}

let unlinked = comparison.unlinkedWordLocations
```

``SwordWordLink`` supports one-to-many alignment across Greek, Hebrew, and
translations. ``SwordVerseComparison/unlinkedWordLocations`` preserves words
that cannot be aligned instead of silently discarding them.
