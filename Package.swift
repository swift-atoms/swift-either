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
                .product(name: "Hash", package: "swift-hash"),
                .target(name: "Either Test Support"),
                .target(name: "Either Foundation Integration"),
            ],
            path: "Tests/Either Tests"
        ),
        .testTarget(
            name: "Consolidated Either Comparison Tests",
            dependencies: [

                .target(name: "Either"),
                .product(name: "Comparison", package: "swift-comparison"),
            ],
            path: "Tests/Consolidated swift-either-comparison"
        ),
        .testTarget(
            name: "Consolidated Either Equation Tests",
            dependencies: [

                .target(name: "Either"),
                .product(name: "Equation", package: "swift-equation"),
            ],
            path: "Tests/Consolidated swift-either-equation"
        ),
        .testTarget(
            name: "Consolidated Either Hash Tests",
            dependencies: [
                .product(name: "Equation", package: "swift-equation"),

                .target(name: "Either"),
                .product(name: "Hash", package: "swift-hash"),
            ],
            path: "Tests/Consolidated swift-either-hash"
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
