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

// Lint executable — leaf-triage consumer for the three-tier rules hierarchy
// (swift-primitives-linter-rules → swift-institute-linter-rules →
// swift-linter-rules). One bundle, one engine call. New rules added at
// any tier propagate here on the next dependency-resolution; this file
// does not need editing.

internal import Linter
internal import Linter_Primitives_Rules

Lint.run(bundle: Lint.Rule.Bundle.primitives)
