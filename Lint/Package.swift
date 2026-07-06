// swift-tools-version: 6.3.1

// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-either-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-either-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Lint executable — leaf-triage consumer for the three-tier rules hierarchy.
//
// Two direct deps only: the engine and the primitives-tier rules
// bundle. SwiftPM resolves institute + universal transitively through
// the bundle's package chain. The Lint executable's main.swift is a
// single line; new rules added at any tier propagate here without
// editing this file.
//
// Tier semantics (per
// `swift-institute/Research/three-tier-linter-rules-partition.md`):
//   universal  — Swift hygiene, applies to any Swift codebase
//   institute  — applies to L1 primitives + L2 standards + L3 foundations
//   primitives — applies to L1 primitives ONLY (sibling of foundations/standards rules)

import PackageDescription

let package = Package(
    name: "Lint",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .executable(
            name: "Lint",
            targets: ["Lint"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-linter.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-primitives-linter-rules.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "Lint",
            dependencies: [
                .product(name: "Linter", package: "swift-linter"),
                .product(name: "Linter Primitives Rules", package: "swift-primitives-linter-rules"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
