// Comparison.Protocol+Either.swift
// Conformance of Either to Comparison.Protocol.
//
// The institute protocol handles Swift version differences internally:
// under Swift <6.4 Comparison.Protocol is its own protocol fork; under
// Swift 6.4+ it is a typealias to Swift.Comparable per SE-0499. The
// `borrowing Self` operator works in both worlds.
//
// Comparison.Protocol refines Equation.Protocol; the sibling Equation
// conformance in this same target supplies the inherited conformance.
//
// Ordering convention (matching Haskell's derived `Ord (Either a b)`):
// `.left` cases sort before `.right` cases regardless of payload; within
// the same case, payloads are compared.

extension Either: Comparison.`Protocol`
where
    Left: Comparison.`Protocol` & ~Copyable & ~Escapable,
    Right: Comparison.`Protocol` & ~Copyable & ~Escapable
{
    /// Returns whether the left-hand side either is less than the right-hand
    /// side under the lexicographic ordering: `.left(_) < .right(_)` for any
    /// payloads, with payloads compared within a matching case.
    ///
    /// - Note: Uses `@_disfavoredOverload` so the stdlib `Swift.Comparable`
    ///   conformance is preferred when both arms are Copyable.
    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Either, rhs: borrowing Either) -> Bool {
        switch lhs {
        case .left(let lLeft):
            switch rhs {
            case .left(let rLeft):
                return lLeft < rLeft

            case .right:
                return true
            }

        case .right(let lRight):
            switch rhs {
            case .left:
                return false

            case .right(let rRight):
                return lRight < rRight
            }
        }
    }
}
