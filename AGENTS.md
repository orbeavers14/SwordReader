# SwordReader Agent Instructions

## Project

SwordReader is a multiplatform SwiftUI Bible app and reference consumer for the
public SwordKit package. It targets iOS, iPadOS, and macOS.

## Required workflow

Work on one roadmap milestone at a time.

For every milestone:

1. Inspect the existing implementation.
2. Write or update tests first when practical.
3. Implement the smallest complete change.
4. Run the macOS test suite and generic iOS build described in `README.md`.
5. Do not commit unless all tests and builds pass.
6. Review the diff for unrelated changes.
7. Commit the completed milestone with a descriptive message.
8. Stop after the commit unless explicitly instructed to continue.

## SwordKit boundary

Depend on a tagged public SwordKit release. Do not patch or vendor SwordKit in
this repository. Reproduce framework defects in SwordKit, fix and release them
there, and then update this app's dependency.

## Testing

Use Swift Testing only:

```swift
import Testing
```
