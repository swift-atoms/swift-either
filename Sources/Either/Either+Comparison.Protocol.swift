extension Either: Comparison::Comparison.`Protocol`
where
    Left: Comparison::Comparison.`Protocol` & ~Copyable,
    Right: Comparison::Comparison.`Protocol` & ~Copyable
{

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
