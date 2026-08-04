# Persisting Study Data

Use SwordKit's immutable study values as domain models while keeping database and
sync policy in the application.

## Choose the appropriate value

SwordKit includes focused values for common study features:

- ``SwordFavorite`` for a lightweight saved verse;
- ``SwordBookmark`` for a saved location with an optional label;
- ``SwordHighlight`` for a style and optional text range;
- ``SwordNote`` for user-authored text;
- ``SwordReadingHistoryEntry`` for access history;
- ``SwordSavedSearch`` for reproducible search options;
- ``SwordVerseCollection`` for named groups of references; and
- ``SwordReadingPlan`` with ``SwordReadingPlanProgress`` for scheduled reading.

These values contain portable identities such as module name and canonical
reference rather than live module handles.

## Own serialization

Study values are not a promised database schema. Applications choose Core Data,
SwiftData, CloudKit, files, or another persistence system and own schema
migration.

Persist enough identity to recover when a module is unavailable:

```swift
let bookmark = SwordBookmark(
    reference: try SwordReference("Romans 8:28"),
    moduleName: "KJV",
    label: "Encouragement"
)
```

The app can still display the reference and label while offering to restore the
missing module.

## Treat values as immutable revisions

Operations such as ``SwordNote/updating(content:at:)`` and
``SwordReadingPlanProgress/completing(dayID:)`` return new values. Persist the
replacement rather than expecting reference semantics.

## Separate module and user data

Removing a SWORD module should not automatically delete notes, highlights,
history, or collections. Module content is restorable engine data; study content
is user-owned data with its own backup and synchronization requirements.
