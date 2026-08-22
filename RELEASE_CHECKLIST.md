# SwordReader Release Checklist

Run `./Scripts/release-check.sh` before creating an archive. The script checks
privacy and icon metadata, rejects placeholder identifiers, runs the macOS test
suite, and builds all current platforms with Release optimization.

## Apple Developer setup

- Register `com.orbeavers14.SwordReader` for iOS and iPadOS.
- Register `com.orbeavers14.SwordReader.mac` for macOS.
- Register `com.orbeavers14.SwordReader.watchkitapp` for watchOS and associate
  it with the iOS companion.
- Enable Handoff for the iOS and macOS identifiers and confirm the
  `com.orbeavers14.SwordReader.reading` activity type on both platforms.
- Select the distribution team in Xcode, allow automatic signing to create
  profiles, and verify a signed archive for each shipping app.

## Physical-device acceptance

- Install, update, select, and remove at least one small and one large Bible
  module on iPhone, iPad, Mac, and Watch.
- Confirm Watch standalone download and paired iPhone transfer, including
  interruption and retry behavior.
- Confirm chapter navigation, broad search, bookmarks, notes, reading plans,
  reminders, and Dark Mode at the largest accessibility text size.
- Confirm Handoff in both directions, including the missing-translation choice.
- Test offline launch and reading after force-quitting every app.
- Verify VoiceOver reading order, Switch Control focus, hardware-keyboard
  navigation on iPad, and keyboard commands on Mac.

## App Store and TestFlight

- Supply a public support URL and privacy-policy URL matching the in-app privacy
  disclosure and the repository privacy summary.
- Answer App Privacy with no collection and no tracking; re-audit this whenever
  a dependency or network feature changes.
- Review every bundled and downloadable module's distribution terms. Do not
  place third-party Bible content in screenshots without permission.
- Capture localized screenshots for iPhone, iPad, Mac, and Watch using public-
  domain module content.
- Upload a signed build, complete export-compliance questions, and distribute
  to internal testers before external TestFlight review.
- Record crashes, thermal behavior, storage growth, module download failures,
  and accessibility feedback before promoting a release candidate.
