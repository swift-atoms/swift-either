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
        .library(name: "Either Standard Library Integration", targets: ["Either Standard Library Integration"]),
        .library(name: "Either Foundation Library Integration", targets: ["Either Foundation Library Integration"]),
        .library(name: "Either Test Support", targets: ["Either Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-equation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-hash.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-comparison.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Either",
            dependencies: [
                .product(name: "Equation", package: "swift-equation"),
                .product(name: "Hash", package: "swift-hash"),
                .product(name: "Comparison", package: "swift-comparison"),
            ],
            path: "Sources/Either"
        ),
        .target(
            name: "Either Standard Library Integration",
            dependencies: [
                .target(name: "Either"),
            ],
            path: "Sources/Either Standard Library Integration"
        ),
        .target(
            name: "Either Foundation Library Integration",
            dependencies: [
                .target(name: "Either"),
                .target(name: "Either Standard Library Integration"),
            ],
            path: "Sources/Either Foundation Library Integration"
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
                .product(name: "Hash Standard Library Integration", package: "swift-hash"),
                .target(name: "Either Test Support"),
                .target(name: "Either Standard Library Integration"),
                .target(name: "Either Foundation Library Integration"),
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
