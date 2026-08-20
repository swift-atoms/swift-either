// Either+Equation.Protocol.swift
// Conformance of Either to Equation.Protocol — unconditional.

extension Either: Equation.`Protocol`
where
    Left: Equation.`Protocol` & ~Copyable,
    Right: Equation.`Protocol` & ~Copyable
{
    /// Returns whether two `Either` values are equal, comparing payloads only within a matching case.
    @inlinable
    @_disfavoredOverload
    public static func == (lhs: borrowing Either, rhs: borrowing Either) -> Bool {
        switch lhs {
        case .left(let lLeft):
            switch rhs {
            case .left(let rLeft):
                return lLeft == rLeft

            case .right:
                return false
            }

        case .right(let lRight):
            switch rhs {
            case .left:
                return false

            case .right(let rRight):
                return lRight == rRight
            }
        }
    }
}
