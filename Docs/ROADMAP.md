# SwordKit Roadmap

SwordKit is being developed incrementally, with each phase building on
the native bridge and Swift API established in the preceding phases.

## 0.1.0 — Foundation and Module Discovery

- [x] Create the Swift package
- [x] Vendor the CrossWire SWORD source
- [x] Add a reproducible native build
- [x] Link SWORD statically
- [x] Add the C-compatible bridge
- [x] Report bridge and SWORD engine versions
- [x] Discover installed modules
- [x] Expose module metadata through Swift
- [x] Add case-insensitive module lookup
- [x] Add shared native-manager ownership
- [x] Add opaque native module handles

## 0.2.0 — Scripture Retrieval

- [ ] Add `SwordReference`
- [ ] Add `SwordVerse`
- [ ] Set a module reference
- [ ] Retrieve rendered verse text
- [ ] Normalize returned references
- [ ] Report invalid or unavailable references
- [ ] Retrieve verse ranges

## 0.3.0 — Passage Navigation

- [ ] Add `SwordPassage`
- [ ] Retrieve complete chapters
- [ ] Iterate through verses
- [ ] Navigate between chapters
- [ ] Navigate between books
- [ ] Expose canonical book metadata

## 0.4.0 — Search

- [ ] Search within one module
- [ ] Support phrase and keyword searches
- [ ] Return structured search results
- [ ] Support scoped book and testament searches
- [ ] Report search progress and cancellation

## 0.5.0 — Parallel Translation Study

- [ ] Retrieve one reference from multiple Bible modules
- [ ] Add a structured verse-comparison result
- [ ] Align parallel translations by canonical reference
- [ ] Handle modules with different versification systems
- [ ] Provide APIs suitable for side-by-side reader interfaces

## 0.6.0 — Original-Language Study

- [ ] Preserve structured SWORD markup
- [ ] Expose Greek and Hebrew source text
- [ ] Parse word-level lemma annotations
- [ ] Expose Strong's identifiers
- [ ] Expose morphology codes
- [ ] Connect words to installed lexicon modules
- [ ] Add structured interlinear results
- [ ] Support transliteration and gloss data when available

## 0.7.0 — Reference Resources

- [ ] Retrieve dictionary and lexicon entries
- [ ] Retrieve commentary entries
- [ ] Associate resources with canonical references
- [ ] Discover module capabilities and features
- [ ] Expose module copyright and licensing metadata

## 0.8.0 — Module Management

- [ ] Discover configured repositories
- [ ] List available remote modules
- [ ] Install modules
- [ ] Update modules
- [ ] Remove modules
- [ ] Report download and installation progress

## Application-Level Features

These features may live in example applications or separate packages rather
than the core SwordKit library.

- [ ] macOS reader
- [ ] iPhone and iPad reader
- [ ] Bookmarks
- [ ] Notes
- [ ] Highlights
- [ ] Reading plans
- [ ] Cloud synchronization
- [ ] Apple Pencil notes
- [ ] Siri shortcuts

## 1.0.0 — Stable API

- [ ] Finalize public naming and ownership semantics
- [ ] Document every public declaration
- [ ] Establish concurrency guarantees
- [ ] Add complete integration tests
- [ ] Add continuous integration
- [ ] Publish migration and compatibility policies

2.0 Vision

□ Parallel translation engine

□ Interlinear engine

□ Strong's lexicon

□ Morphology parsing

□ Dictionary popovers

□ Commentary synchronization

□ Cross references

□ Original-language search

□ Reading workspace

□ Split panes

□ Multi-column comparison

□ Study layouts
