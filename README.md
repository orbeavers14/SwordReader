# SwordKit

SwordKit is a modern Swift framework for building offline Bible applications on Apple platforms.

## Goals

- Native Swift API
- SwiftUI-first
- Offline Bible study
- Fast search
- Parallel translations
- Notes, bookmarks, and highlights
- Cross-platform (macOS, iOS, iPadOS)

## Architecture

```
SwiftUI App
        ↓
SwordKit
        ↓
CSwordBridge
        ↓
libsword
```

The SWORD engine is vendored in `Vendor/libsword` and treated as a third-party dependency.
