# SwordKit Migration Guide Template

Use this structure for every release that changes public names, behavior,
platform minimums, concurrency, native artifacts, or persisted-data assumptions.

## Migration scope

- Previous version or commit range:
- New version:
- Minimum Swift and Xcode versions:
- Affected Apple platforms:
- Source compatibility: compatible or breaking
- Data migration required: yes or no

## Summary

Describe the user-visible reason for the change and identify who must act.

## Changed APIs

For each change, include:

1. The previous declaration or behavior.
2. The replacement declaration or behavior.
3. A minimal before-and-after example.
4. Error-handling, threading, storage, or deployment consequences.

## Native artifact changes

Record changes to the vendored SWORD revision, feature flags, XCFramework slices,
linked system libraries, or package distribution method.

## Persisted application data

State whether references, module identities, study values, or host-owned schemas
need transformation. SwordKit domain values must not be described as a stable
database schema unless a release explicitly establishes one.

## Platform considerations

Document different migration steps for macOS, iOS/iPadOS, tvOS, visionOS, and
watchOS when their storage or lifecycle behavior differs.

## Validation checklist

- [ ] The package builds for every supported destination.
- [ ] The complete Swift test suite passes.
- [ ] DocC builds without unresolved links or warnings.
- [ ] Existing modules remain readable.
- [ ] Installation, removal, and refresh work in app-owned storage.
- [ ] Search cancellation and progress behavior remain correct.
- [ ] Release notes link to this guide.
