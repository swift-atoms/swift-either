# Either, Result, and Typed Throws

@Metadata {
    @TitleHeading("Either Primitives")
}

`Either`, the standard library's `Result`, and Swift's typed throws (SE-0413) cover overlapping ground but serve distinct roles. They are complementary — picking one over the others is a matter of which axis the call site is on, not which is "newer" or "better".

## Decision Table

| Use case | Tool |
|----------|------|
| Single error domain in a throw site | `throws(E)` directly |
| Two-or-more error domains in one throw site | `throws(Either<E1, E2>)` (right-nested for N ≥ 3) |
| Validation accumulation across independent steps | `Validation<Failure: Semigroup, Success>` (deferred to `swift-validation-primitives`) |
| Symmetric-disjunction return value (no privileged failure side) | `-> Either<L, R>` |
| Asymmetric success/failure return value, `Copyable` success | `-> Result<S, F>` |
| Asymmetric success/failure return value, `~Copyable` success | `-> Standard_Library_Extensions.Result<S, F>` |

## Single Error Domain

Use `throws(E)` directly. There is no role for `Either` when a function fails with exactly one error type.

```swift
// Pre-typed-throws era:
func parse() -> Either<ParseError, Document>

// Typed-throws era:
func parse() throws(ParseError) -> Document
```

The second form integrates with `try`, `catch`, `do`, async, and `Result.init(catching:)`. It is strictly cleaner for the single-domain case.

## Multiple Error Domains

Use `throws(Either<E1, E2>)`. Typed throws requires a single error type: `throws(E)` where `E: Error`. When the function genuinely fails for two distinct reasons, the two error types must be combined — and the combination is precisely a binary coproduct.

```swift
// Two error domains: the parser's own error and a cross-cutting interrupt.
func writeAll(_ bytes: [UInt8]) throws(Either<IO.Error, Interrupt>)

// Three or more: right-nest.
func step() throws(Either<E1, Either<E2, E3>>)
```

SE-0413 itself names `Either` as the under-the-hood mechanism for opaque-error combination:

> For example, one could use a suitable `Either` type under the hood: `func doSomething() throws(some Error)` …

— *Swift Evolution proposal SE-0413, "Opaque thrown error types".*

`Either` conditionally conforms to `Swift.Error` when both arms do, which is precisely the constraint typed throws requires:

```swift
extension Either: Swift.Error where Left: Swift.Error, Right: Swift.Error {}
```

This is the load-bearing role for `Either` in the institute ecosystem. The pattern appears at 14+ existing call sites across 7 packages — parser combinators, kernel I/O, semaphores, pool acquisition, binary access — wherever a function throws two distinct error types. See `Research/api-design-property-leverage.md` for the inventory.

## Validation Accumulation

Use `Validation`, not `Either`. When a pipeline runs independent steps and wants to *collect* every failure rather than short-circuit on the first, the right shape is `Validation<Failure: Semigroup, Success>`. `Either` is short-circuit by construction: it holds exactly one value. Accumulating multiple failures requires a `Semigroup` instance over the failure type.

`Validation` is deferred to a future `swift-validation-primitives` package. Until it ships, the institute pattern is to fold per-step `Result`s with an explicit accumulator at the call site.

## Symmetric Disjunction

Use `Either`. When neither side is privileged as "the failure" — when both arms are legitimate, value-bearing outcomes — `Either` is the right return type.

```swift
func classify(_ token: Token) -> Either<Identifier, Keyword>
```

A parser case that yields one of two structured outputs, a classifier whose two branches are both valid, a dual-path state machine — these are coproducts, not error channels. `Result` is the wrong shape because it asymmetrically privileges `.failure`.

## Asymmetric Outcome

Use `Result`. When the call site has a privileged success path and a privileged failure path, the standard library's `Result<Success, Failure>` is the right shape. Its API surface — `map`, `flatMap`, `mapError`, `flatMapError`, `init(catching:)` — is built around that asymmetry.

For `~Copyable` success values — file handles, unique resources, anything that cannot be silently duplicated — use the institute's `~Copyable`-aware Result at `Standard_Library_Extensions.Result<Success, Failure>` where `Success: ~Copyable`. It carries the same API shape as `Swift.Result` on the `Copyable` path and adds a consuming `get()` on the `~Copyable` path.

`Either` provides a one-direction interop initializer for the SLE Result:

```swift
extension Either where Left: Swift.Error /* Right: ~Copyable */ {
    public init(_ result: Standard_Library_Extensions.Result<Right, Left>)
}
```

Constructing an `Either` from an SLE `Result` lets a `throws(Either<Failure, OtherFailure>)` site consume an SLE `Result` without writing a 5-line `switch`. The reverse direction (`Result.init(_ either:)`) is intentionally not provided: it would require extending the standard library's `Result`, and the equivalent `either.fold(left: { .failure($0) }, right: { .success($0) })` is one line at the call site.

No interop is provided for `Swift.Result`. Consumers holding a stdlib `Result` can call `.fold(...)` on the institute side or migrate to the SLE Result. The package keeps a single Result-direction interop to avoid surface duplication.

## Summary

Typed throws does not subsume `Either`. They share the error channel, but typed throws requires one error type per throw site, and `Either` is the type-level combinator that lets a single throw site carry two. `Result` is the asymmetric cousin: same domain (success-or-failure), different ergonomic priority. Pick by the axis of the call site:

- *How many error types does this throw site carry?* — 1: `throws(E)`. ≥ 2: `throws(Either<E1, E2>)`.
- *Is one side privileged as "the failure"?* — yes: `Result`. no: `Either`.
- *Is the success side `~Copyable`?* — yes: `Standard_Library_Extensions.Result`. no: `Swift.Result`.

## See Also

- ``Either_Primitives/Either``
- [SE-0413 — Typed throws](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0413-typed-throws.md)
