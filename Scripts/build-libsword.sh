#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SWORD_SOURCE_DIR="${PROJECT_ROOT}/Vendor/libsword"
SWORD_BUILD_DIR="${SWORD_SOURCE_DIR}/build"
SWORD_LIBRARY="${SWORD_BUILD_DIR}/libsword.a"

MACOS_DEPLOYMENT_TARGET="${MACOS_DEPLOYMENT_TARGET:-14.0}"
BUILD_TYPE="${BUILD_TYPE:-Release}"

echo "Building libsword"
echo "Source: ${SWORD_SOURCE_DIR}"
echo "Build:  ${SWORD_BUILD_DIR}"
echo "Type:   ${BUILD_TYPE}"
echo "macOS:  ${MACOS_DEPLOYMENT_TARGET}"
echo

if ! command -v cmake >/dev/null 2>&1; then
    echo "Error: CMake is not installed or is not available in PATH."
    echo "Install it with:"
    echo "  brew install cmake"
    exit 1
fi

if [[ ! -f "${SWORD_SOURCE_DIR}/CMakeLists.txt" ]]; then
    echo "Error: SWORD source was not found at:"
    echo "  ${SWORD_SOURCE_DIR}"
    exit 1
fi

rm -rf "${SWORD_BUILD_DIR}"

cmake \
    -S "${SWORD_SOURCE_DIR}" \
    -B "${SWORD_BUILD_DIR}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOS_DEPLOYMENT_TARGET}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5

# Build only the static SWORD target. This prevents SwiftPM from
# accidentally linking against a generated dynamic library.
cmake \
    --build "${SWORD_BUILD_DIR}" \
    --target sword_static \
    --parallel

# Safeguard against accidentally retaining dynamic SWORD libraries.
find "${SWORD_BUILD_DIR}" -maxdepth 1 \
    \( -name 'libsword*.dylib' -o -name 'libsword*.so' \) \
    -delete

if [[ ! -f "${SWORD_LIBRARY}" ]]; then
    echo
    echo "Error: The static SWORD library was not created:"
    echo "  ${SWORD_LIBRARY}"
    exit 1
fi

echo
echo "libsword built successfully:"
ls -lh "${SWORD_LIBRARY}"
