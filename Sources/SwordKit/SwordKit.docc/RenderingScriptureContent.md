# Rendering Scripture Content

Choose plain text, XHTML, or attributed text without coupling the engine to an
application's UI framework.

## Start with immutable verse content

``SwordVerse`` carries plain text plus optional lexical attributes, footnotes,
cross-references, and headings:

```swift
let verse = try bible.verse("John 3:16")

print(verse.text)
print(verse.footnotes)
print(verse.crossReferences)
```

Use these values when the application needs complete control over layout and
interaction.

## Render XHTML

`SwordModule.html(_:)` returns SWORD-generated XHTML:

```swift
let html = try bible.html("John 3:16")
```

Treat the result as module content, not as a complete web page. The host app owns
CSS, navigation handling, accessibility, and any web-view security policy.

## Render attributed text

`SwordModule.attributedString(_:)` converts supported XHTML to a Swift
`AttributedString` and applies SwordKit lexical attributes:

```swift
let attributed = try bible.attributedString("John 3:16")
```

Strong's-number and morphology attributes are present only when the installed
module provides the required word data. Always support plain-text fallback.

## Present structural annotations

Use ``SwordHeading/position`` to distinguish pre-verse and inter-verse headings.
Use ``SwordFootnote/type`` and ``SwordFootnote/referenceList`` to decide whether
a note opens commentary content or Scripture navigation.

Do not persist rendered XHTML as canonical Scripture data. Persist stable module
and reference identity, then render again so module updates remain observable.
