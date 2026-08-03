#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_ROOT="${PROJECT_ROOT}/.build/sword-apple"
OUTPUT="${PROJECT_ROOT}/Artifacts/Sword.xcframework"

DESTINATIONS=(
    macos
    ios
    ios-simulator
    tvos
    tvos-simulator
    visionos
    visionos-simulator
    watchos
    watchos-simulator
)

arguments=()

for destination in "${DESTINATIONS[@]}"; do
    library="${BUILD_ROOT}/${destination}/libsword.a"

    if [[ ! -f "${library}" ]]; then
        echo "Error: Missing native library for ${destination}:"
        echo "  ${library}"
        echo
        echo "Build every slice first with:"
        echo "  ./Scripts/build-libsword-apple.sh all"
        exit 1
    fi

    arguments+=(-library "${library}")
done

rm -rf "${OUTPUT}"

xcodebuild -create-xcframework \
    "${arguments[@]}" \
    -output "${OUTPUT}"

echo
echo "Created ${OUTPUT}"
