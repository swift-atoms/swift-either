# ``Either_Primitives``

@Metadata {
    @DisplayName("Either Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

The binary coproduct type for typed sum values.

## Overview

`Either Primitives` ships ``Either_Primitives/Either``, a generic sum type
representing the categorical coproduct `Left + Right`. Where a binary
product (`Pair`) holds *both* values, `Either` holds *exactly one*.

Use `Either` for typed disjoint alternatives that carry their own value —
classifier-tagged outputs, parser results, dual-path state machines, and
any place where one of two unrelated types is the right answer. SE-0413
(Typed Throws) reaches for an `Either` shape pedagogically when discussing
how `throws(some Error)` could combine multiple thrown types under the
hood; the proposal does not require it as an implementation. This type is
the public realisation for cases where a typed sum is what you want.

`Either` is `~Copyable & ~Escapable` at the type level with conditional
`Copyable`, `Escapable`, `Sendable`, `BitwiseCopyable`, `Equatable`,
`Hashable`, `Codable`, and `Error` conformances based on its components.
The functor surface — `map(left:)`, `map(right:)`, `map(left:right:)` —
uses labeled overloads on a single `map` verb. The catamorphism
`fold(left:right:)` collapses an `Either` into a single value.
`swapped()` exchanges the arms. When one side is `Never`, the `value`
accessor extracts the inhabited side unconditionally.

## Lifecycle: movement, not management

`Either` is a *movement vehicle* — it transports one of two alternative
values. It does NOT close, unlock, or otherwise act on its component on
drop. Lifecycle decisions belong to the consumer, typically via `swapped`
or `value(of:)` extraction.

## ~Escapable arm support

Both arms may be `~Copyable` and `~Escapable`. Non-closure operations —
construction, `swapped()`, the `value(of:)` free function for
`Never`-eliminated arms, and the institute-protocol conformances
(`Equation.Protocol`, `Hash.Protocol`, `Comparison.Protocol`) — admit
`~Escapable` arms today. Closure-bearing methods admit `~Escapable` on
the un-transformed arm only; both arms `~Escapable` through a closure is
currently blocked by Swift's lifetime-from-closure-result limitation. The
`.left` / `.right` peek accessors admit `Copyable & ~Escapable` arms with
lifetime tied to the borrowed receiver.

## Topics

### The Coproduct

- ``Either_Primitives/Either``
