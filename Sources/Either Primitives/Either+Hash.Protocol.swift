// Either+Hash.Protocol.swift
// Conformance of Either to Hash.Protocol — unconditional.
//
// On Swift <6.4, `Hash.Protocol` is the institute fork supporting
// `borrowing self` for `~Copyable` arms. On Swift 6.4+, it is a typealias
// to `Swift.Hashable` per SE-0499 — this same extension then satisfies the
// stdlib conformance directly. The stdlib `extension Either: Hashable
// where Left: Hashable, Right: Hashable {}` in `Either.swift` is therefore
// guarded `#if swift(<6.4)` to avoid duplicate-conformance.
//
// Hash.Protocol refines Equation.Protocol; the sibling Equation
// conformance in this same target supplies the inherited conformance.

#if swift(<6.4)
extension Either: Hash.`Protocol`
where
    Left: Hash.`Protocol` & ~Copyable & ~Escapable,
    Right: Hash.`Protocol` & ~Copyable & ~Escapable
{
    /// Hashes the essential components of this either value into the given hasher.
    ///
    /// The case discriminator (`.left` vs `.right`) is folded into the hash
    /// alongside the payload's own hash. This ensures that `Either<L, R>`
    /// values with structurally identical payloads but different cases produce
    /// different hashes, preserving the equals/hashCode contract alongside `==`.
    ///
    /// - Note: Uses `@_disfavoredOverload` so the stdlib `Swift.Hashable`
    ///   synthesized conformance is preferred for Copyable arms on Swift
    ///   <6.4; the move-only borrowing path is selected when at least one
    ///   arm is `~Copyable`.
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        switch self {
        case .left(let left):
            hasher.combine(0 as UInt8)
            left.hash(into: &hasher)

        case .right(let right):
            hasher.combine(1 as UInt8)
            right.hash(into: &hasher)
        }
    }
}
#else
// Swift 6.4+: Hash.Protocol REFINES Swift.Hashable (typed hashValue). A conditional
// conformance to it does not synthesize the inherited Swift.Hashable, so declare it
// explicitly with the hash(into:) witness; the Hash.Protocol conformance is then empty
// (typed hashValue defaulted in hash-primitives). Equatable comes from the sibling
// Equation.Protocol conformance (still a Swift.Equatable typealias).
// Ref: Research/se-0499-…md Addendum (2026-06-01).
extension Either: Swift.Hashable
where
    Left: Hash.`Protocol` & ~Copyable,
    Right: Hash.`Protocol` & ~Copyable
{
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        switch self {
        case .left(let left):
            hasher.combine(0 as UInt8)
            left.hash(into: &hasher)

        case .right(let right):
            hasher.combine(1 as UInt8)
            right.hash(into: &hasher)
        }
    }
}

extension Either: Hash.`Protocol`
where
    Left: Hash.`Protocol` & ~Copyable,
    Right: Hash.`Protocol` & ~Copyable
{}
#endif
