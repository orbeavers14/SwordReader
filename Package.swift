// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwordKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SwordKit",
            targets: ["SwordKit"]
        )
    ],
    targets: [
    .target(
        name: "CSwordBridge",
        path: "Sources/CSwordBridge",
        publicHeadersPath: "include",
        cxxSettings: [
            .headerSearchPath("../../Vendor/libsword/include")
        ],
        linkerSettings: [
            .unsafeFlags([
                "-LVendor/libsword/build",
                "-lsword"
            ])
        ]
    ),
    .target(
        name: "SwordKit",
        dependencies: ["CSwordBridge"],
        path: "Sources/SwordKit"
    ),
    .testTarget(
        name: "SwordKitTests",
        dependencies: ["SwordKit"],
        path: "Tests/SwordKitTests"
    )
],
    cxxLanguageStandard: .cxx17
)