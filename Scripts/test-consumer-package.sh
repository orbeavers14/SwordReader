#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONSUMER_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/swordkit-consumer.XXXXXX")"

cleanup() {
    rm -rf "${CONSUMER_ROOT}"
}
trap cleanup EXIT

ln -s "${PROJECT_ROOT}" "${CONSUMER_ROOT}/SwordKit"
mkdir -p "${CONSUMER_ROOT}/Sources/SwordKitConsumer"

cat > "${CONSUMER_ROOT}/Package.swift" <<'PACKAGE'
// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwordKitConsumer",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "SwordKit")
    ],
    targets: [
        .executableTarget(
            name: "SwordKitConsumer",
            dependencies: [
                .product(name: "SwordKit", package: "SwordKit")
            ]
        )
    ]
)
PACKAGE

cat > "${CONSUMER_ROOT}/Sources/SwordKitConsumer/main.swift" <<'SWIFT'
import SwordKit

precondition(!SwordLibrary.bridgeVersion.isEmpty)
precondition(!SwordLibrary.engineVersion.isEmpty)

print("SwordKit consumer linked bridge \(SwordLibrary.bridgeVersion)")
print("SwordKit consumer linked SWORD \(SwordLibrary.engineVersion)")
SWIFT

swift run \
    --package-path "${CONSUMER_ROOT}" \
    SwordKitConsumer
