#!/bin/bash

set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
release_tmp="$(mktemp -d "${TMPDIR:-/tmp}/swordreader-release.XXXXXX")"
derived_data="$release_tmp/DerivedData"

cleanup() {
    rm -rf "$release_tmp"
}
trap cleanup EXIT

cd "$project_root"

echo "Validating release metadata"
plutil -lint \
    SwordReader/PrivacyInfo.xcprivacy \
    SwordReaderWatch/PrivacyInfo.xcprivacy \
    Support/SwordReader-Info.plist \
    Support/SwordReaderMac-Info.plist \
    Support/SwordReaderWatch-Info.plist

jq empty \
    SwordReader/Assets.xcassets/Contents.json \
    SwordReader/Assets.xcassets/AppIcon.appiconset/Contents.json \
    SwordReaderWatch/Assets.xcassets/Contents.json \
    SwordReaderWatch/Assets.xcassets/AppIcon.appiconset/Contents.json

if rg -n 'com\.example|SwordKit 0\.4\.0' \
    README.md ROADMAP.md project.yml Support SwordReader SwordReaderWatch; then
    echo "Release-blocking placeholder or stale dependency metadata remains."
    exit 1
fi

for icon in \
    SwordReader/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png \
    SwordReader/Assets.xcassets/AppIcon.appiconset/AppIcon-Dark-1024.png \
    SwordReader/Assets.xcassets/AppIcon.appiconset/AppIcon-Tinted-1024.png \
    SwordReaderWatch/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png; do
    width="$(sips -g pixelWidth "$icon" | awk '/pixelWidth/ { print $2 }')"
    height="$(sips -g pixelHeight "$icon" | awk '/pixelHeight/ { print $2 }')"
    alpha="$(sips -g hasAlpha "$icon" | awk '/hasAlpha/ { print $2 }')"
    if [[ "$width" != "1024" || "$height" != "1024" || "$alpha" != "no" ]]; then
        echo "$icon must be an opaque 1024×1024 PNG."
        exit 1
    fi
done

for appearance in dark tinted; do
    if ! jq -e --arg appearance "$appearance" \
        '.images[] | select(.platform == "ios") | select(.appearances[]?.value == $appearance)' \
        SwordReader/Assets.xcassets/AppIcon.appiconset/Contents.json >/dev/null; then
        echo "The iOS AppIcon set is missing its $appearance appearance."
        exit 1
    fi
done

echo "Regenerating the Xcode project"
xcodegen generate

common=(
    -project SwordReader.xcodeproj
    -derivedDataPath "$derived_data"
    CODE_SIGNING_ALLOWED=NO
)

echo "Running macOS tests"
xcodebuild test -quiet \
    "${common[@]}" \
    -scheme SwordReader-macOS \
    -destination 'platform=macOS'

echo "Building macOS Release"
xcodebuild build -quiet \
    "${common[@]}" \
    -scheme SwordReader-macOS \
    -configuration Release \
    -destination 'platform=macOS'

echo "Building iOS/iPadOS Release"
xcodebuild build -quiet \
    "${common[@]}" \
    -scheme SwordReader \
    -configuration Release \
    -destination 'generic/platform=iOS'

echo "Building watchOS Release"
xcodebuild build -quiet \
    "${common[@]}" \
    -scheme SwordReader-watchOS \
    -configuration Release \
    -destination 'generic/platform=watchOS'

echo "SwordReader release checks passed."
