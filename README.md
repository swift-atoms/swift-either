# Either Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

`Either<Left, Right>` — a generic sum type holding *exactly one* of two alternatives. The categorical coproduct: where a binary product holds both values, `Either` holds one. `~Copyable & ~Escapable` at the type level, with conditional `Copyable`, `Escapable`, `Sendable`, `BitwiseCopyable`, `Equatable`, `Hashable`, `Codable`, `Error`, `Equation.Protocol`, `Hash.Protocol`, and `Comparison.Protocol` conformances based on its components. The functor surface — `map(left:)` / `map(right:)` / `map(left:right:)` / `flatMap(left:)` / `flatMap(right:)` / `fold(left:right:)` / `swapped()` — uses labeled overloads on a single verb.

Use `Either` for typed disjoint alternatives that carry their own value — classifier-tagged outputs, dual-path state, parser branches. SE-0413 (Typed Throws) reaches for an `Either` shape pedagogically when discussing how `throws(some Error)` could combine multiple thrown types under the hood; the proposal does not require it as an implementation. This package is the public type for cases where a typed sum is what you want. For the error-channel variant where one side is privileged as "the failure", the standard library's `Result<T, E>` is the right tool; `Either` is for sum cases where neither side is privileged.

---

## Quick Start

```swift
import Either_Primitives

let success: Either<String, Int> = .right(42)
let failure: Either<String, Int> = .left("not found")

let doubled = success.map(right: { $0 * 2 })   // .right(84)
let flipped = success.swapped()                 // Either<Int, String>.left(42)
```

`Never` on either side eliminates the case unconditionally:

```swift
let certain: Either<Never, Int> = .right(10)
print(certain.value)  // 10 — left side is uninhabited
```

`map(left:right:)` transforms both arms in one pass:

```swift
let labelled: Either<String, Int> = .right(7)
let widened = labelled.map(
    left:  { "error: \($0)" },
    right: { Double($0) }
)   // Either<String, Double>.right(7.0)
```

`fold(left:right:)` collapses an `Either` into a single value by handling
both cases — the universal property of the coproduct:

```swift
let message = either.fold(
    left:  { walkError in describe(walkError) },
    right: { userError in describe(userError) }
)
```

Both arms may be `~Copyable` and `~Escapable`. Non-closure operations —
`swapped()`, the `value(of:)` free function for `Never`-eliminated arms,
and the institute-protocol conformances (`Equation.Protocol` / `Hash.Protocol`
/ `Comparison.Protocol`) — admit `~Escapable` arms today. Closure-bearing
methods (`map(left:)`, `map(right:)`, `map(left:right:)`, `flatMap(left:)`,
`flatMap(right:)`, `fold(left:right:)`, equal-arm `map { f }` /
`flatMap { f }`) admit `~Escapable` on the un-transformed arm only; both
arms `~Escapable` through a closure is currently blocked by Swift's
lifetime-from-closure-result limitation. The `.left` / `.right` peek
accessors admit `Copyable & ~Escapable` arms with lifetime tied to the
borrowed receiver; broader peek accessors for `~Copyable` arms are deferred
pending stdlib `Borrow<T>`.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-either-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Either Primitives", package: "swift-either-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

One library product, one target.

| Product | Target | Contents |
|---------|--------|----------|
| `Either Primitives` | `Sources/Either Primitives/` | `Either<Left, Right>` + `map(left:)` / `map(right:)` / `map(left:right:)` / `flatMap(right:)` / `flatMap(left:)` / `fold(left:right:)` / `swapped()` + `.left` / `.right` accessors + `Never`-elimination `value` accessors. |

The conditional conformance ladder mirrors stdlib `Result.swift`'s triple-extension pattern. Conditional `Equation.Protocol`, `Hash.Protocol`, and `Comparison.Protocol` conformances admit `~Copyable` arms — `Either<NCResource, NCResource>` is comparable, hashable, and equation-conforming via the `borrowing` operators when arms conform.

Dependencies (path-resolved at development time): `swift-equation-primitives`, `swift-hash-primitives`, `swift-comparison-primitives`. Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| iOS / tvOS / watchOS / visionOS | Full support |
| Linux | Full support (Swift 6.3 release + Static musl + Android SDK + Embedded Wasm SDK) |
| Windows | Full support (Swift 6.3) |
| Swift Embedded | Full support (Swift 6.4-dev nightly Embedded build); `Codable` is `#if !hasFeature(Embedded)` gated |

---

## Community

<!-- BEGIN: discussion -->
Discuss this package: [swift-institute/discussions/15](https://github.com/orgs/swift-institute/discussions/15)
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
