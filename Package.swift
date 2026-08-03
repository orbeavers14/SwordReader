// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwordKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
        .watchOS(.v10)
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
            dependencies: ["SwordNative"],
            path: "Sources/CSwordBridge",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("../../Vendor/libsword/include")
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("bz2"),
                .linkedLibrary("lzma", .when(platforms: [.macOS])),
                .linkedLibrary("curl", .when(platforms: [.macOS]))
            ]
        ),
        .binaryTarget(
            name: "SwordNative",
            path: "Artifacts/Sword.xcframework"
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
