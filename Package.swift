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
        .library(name: "Either", targets: ["Either"]),

        .library(name: "Either Foundation Integration", targets: ["Either Foundation Integration"]),
        .library(name: "Either Test Support", targets: ["Either Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Either",
            dependencies: [],
            path: "Sources/Either"
        ),
        
        .target(
            name: "Either Foundation Integration",
            dependencies: [
                .target(name: "Either"),
            ],
            path: "Sources/Either Foundation Integration"
        ),
        .target(
            name: "Either Test Support",
            dependencies: [
                .target(name: "Either"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Either Tests",
            dependencies: [
                .target(name: "Either"),
                .target(name: "Either Test Support"),
                .target(name: "Either Foundation Integration"),
            ],
            path: "Tests/Either Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
