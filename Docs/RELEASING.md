# Releasing SwordKit

SwordKit releases are Git tags that identify a tested Swift package revision.
Use Semantic Versioning and the compatibility rules in
[COMPATIBILITY.md](COMPATIBILITY.md).

## Licensing gate

SwordKit is GPL-2.0-only. Confirm that release notes identify the license, retain
SWORD's upstream notices, and explain that Bible modules have independent terms.
Anyone distributing a linked application is responsible for the corresponding
source and redistribution obligations of the combined GPL work.

## Prepare the release

1. Choose the version and create a release branch if stabilization needs more
   than one commit.
2. Move relevant entries from `Unreleased` in `CHANGELOG.md` into a heading for
   the version and release date.
3. Add a migration guide when the compatibility policy requires one.
4. If the vendored SWORD revision changed, rebuild every native slice and package
   `Artifacts/Sword.xcframework` from the same source revision.
5. Confirm that no generated build products or unrelated changes are present.

## Validate the release candidate

Run the required Swift suite:

```bash
./Scripts/test.sh
```

Build the documentation and treat unresolved links or content warnings as
failures:

```bash
xcodebuild docbuild \
  -scheme SwordKit \
  -destination 'generic/platform=macOS' \
  -derivedDataPath .build/docc \
  CODE_SIGNING_ALLOWED=NO
```

The CI platform matrix must also compile the package and tests for iOS/iPadOS,
tvOS, visionOS, and watchOS simulators. Do not tag a revision until every
required check passes.

## Publish

1. Merge the exact validated revision into `main`.
2. Create an annotated tag named with a `v` prefix, such as `v0.1.0`.
3. Push the tag and create release notes from the matching changelog section.
4. Verify that a clean external Swift package can resolve the tag, compile
   SwordKit, and link the bundled XCFramework.

Do not move the XCFramework to URL-based binary distribution until release
hosting, checksums, and artifact availability are automated. The repository-local
artifact remains the supported distribution method for the first release.

## After publishing

Add a fresh `Unreleased` section to `CHANGELOG.md`, verify the published tag from
a clean checkout, and record any known issues in the release notes.
