#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Cleaning SwordKit build products..."

rm -rf "${PROJECT_ROOT}/.build"
rm -rf "${PROJECT_ROOT}/Vendor/libsword/build"

echo "Clean complete."
