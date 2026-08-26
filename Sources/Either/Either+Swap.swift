extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable {

    @inlinable
    @_lifetime(copy either)
    public static func swapped(_ either: consuming Either) -> Either<Right, Left> {
        switch consume either {
        case .left(let left):
            .right(consume left)

        case .right(let right):
            .left(consume right)
        }
    }
}

extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable {

    @inlinable
    @_lifetime(copy self)
    public consuming func swapped() -> Either<Right, Left> {
        Self.swapped(self)
    }
}
