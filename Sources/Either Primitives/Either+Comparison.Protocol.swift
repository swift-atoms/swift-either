// Comparison.Protocol+Either.swift
// Conformance of Either to Comparison.Protocol.

extension Either: Comparison.`Protocol`
where
    Left: Comparison.`Protocol` & ~Copyable,
    Right: Comparison.`Protocol` & ~Copyable
{
    /// Returns whether the left-hand side is ordered before the right-hand side under the
    /// lexicographic ordering: `.left(_) < .right(_)`, with payloads compared within a matching case.
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
