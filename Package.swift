// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-either",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Either",
            targets: ["Either"]
        ),
        .library(
            name: "Either Standard Library Integration",
            targets: ["Either Standard Library Integration"]
        ),
        .library(
            name: "Either Apple Foundation Integration",
            targets: ["Either Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Either",
            dependencies: []
        ),
        .target(
            name: "Either Standard Library Integration",
            dependencies: ["Either"]
        ),
        .target(
            name: "Either Apple Foundation Integration",
            dependencies: [
                "Either",
                "Either Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Either Tests",
            dependencies: ["Either"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
