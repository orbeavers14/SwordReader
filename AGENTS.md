# SwordKit Agent Instructions

## Project

SwordKit is a modern Swift-native wrapper around the CrossWire SWORD C++ library.

The package targets macOS, iOS, and iPadOS.

## Required workflow

Work on one roadmap milestone at a time.

For every milestone:

1. Inspect the existing implementation.
2. Write or update tests first when practical.
3. Implement the smallest complete change.
4. Run:

   ./Scripts/test.sh

5. Do not commit unless all tests pass.
6. Review the diff for unrelated changes.
7. Commit the completed milestone with a descriptive commit message.
8. Stop after the commit unless explicitly instructed to continue.

## Testing

Use Swift Testing only:

```swift
import Testing
```
