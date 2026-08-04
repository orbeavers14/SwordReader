# Building a Translation Comparison

Build a comparison flow that aligns verses across translations and drills down
to Greek, Hebrew, lemma, morphology, and Strong's-number relationships.

## Choose installed modules

Start from stable SWORD module identifiers rather than display titles:

```swift
let requestedModules = ["KJV", "WEB"]

let availableModules = requestedModules.filter {
    library.module(named: $0) != nil
}
```

Applications should preserve the user's requested order and clearly identify
missing modules before retrieval.

## Retrieve aligned passages

Request the same canonical range from every module:

```swift
let parallel = try library.parallelPassage(
    "John 3:16-18",
    modules: availableModules
)
```

Use ``SwordParallelPassage/missingReferences`` to explain gaps rather than
silently shifting verses between columns.

## Present verse-level alignment

Each aligned row retains the canonical reference and the available verse from
each module:

```swift
for row in parallel.alignedVerses {
    print(row.reference.value)

    for moduleName in availableModules {
        let text = row.versesByModule[moduleName]?.text ?? "Missing"
        print(moduleName, text)
    }
}
```

``SwordAlignedVerse/comparison`` provides normalized comparison data without
removing the original display text.

## Detect textual differences

Use ``SwordVerseComparison/hasTextDifferences`` to decide whether the interface
needs to emphasize a row:

```swift
for row in parallel.alignedVerses where row.comparison.hasTextDifferences {
    print("Translations differ at \(row.reference.value)")
}
```

This is a textual signal, not a claim about semantic or theological difference.

## Inspect word tokens

Tokens remain grouped by module and retain linguistic metadata where present:

```swift
let comparison = parallel.alignedVerses[0].comparison

for moduleName in availableModules {
    for token in comparison.tokensByModule[moduleName, default: []] {
        print(
            token.text,
            token.lemma ?? "",
            token.morphology ?? "",
            token.strongsNumber ?? ""
        )
    }
}
```

Modules without lexical attributes still produce normalized text tokens, so the
comparison remains useful for English-only or mixed datasets.

## Follow cross-language links

``SwordVerseComparison/wordLinks`` groups locations that share a Strong's number
across one or more modules:

```swift
for link in comparison.wordLinks {
    let labels = link.locations.map {
        "\($0.moduleName):\($0.token.text)"
    }

    print(link.strongsNumber, labels)
}
```

One link can contain several locations, supporting one-to-many relationships
between source-language words and translations.

## Preserve words without links

Do not discard function words, textual additions, or tokens from modules without
lexical metadata. Present ``SwordVerseComparison/unlinkedWordLocations`` as
unaligned content:

```swift
for location in comparison.unlinkedWordLocations {
    print(location.moduleName, location.token.text)
}
```

This lets an application show both what SwordKit can align and what remains
unresolved, which is essential for honest original-language comparison.
