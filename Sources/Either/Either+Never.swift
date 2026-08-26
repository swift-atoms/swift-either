extension Either where Left == Never {

    @inlinable
    public var value: Right {
        switch self {
        case .right(let right): right
        }
    }
}

extension Either where Right == Never {

    @inlinable
    public var value: Left {
        switch self {
        case .left(let left): left
        }
    }
}

@inlinable
@_lifetime(copy either)
public func value<Right: ~Copyable & ~Escapable>(
    of either: consuming Either<Never, Right>
) -> Right {
    switch consume either {
    case .right(let right): right
    }
}

@inlinable
@_lifetime(copy either)
public func value<Left: ~Copyable & ~Escapable>(
    of either: consuming Either<Left, Never>
) -> Left {
    switch consume either {
    case .left(let left): left
    }
}
