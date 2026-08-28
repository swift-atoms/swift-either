extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable {

    @inlinable
    @_lifetime(copy either)
    public static func map<NewRight: ~Copyable, E: Swift.Error>(
        _ either: consuming Either,
        right transform: (consuming Right) throws(E) -> NewRight
    ) throws(E) -> Either<Left, NewRight> {
        switch consume either {
        case .left(let left):
            .left(consume left)

        case .right(let right):
            try .right(transform(consume right))
        }
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable & ~Escapable {

    @inlinable
    @_lifetime(copy either)
    public static func map<NewLeft: ~Copyable, E: Swift.Error>(
        _ either: consuming Either,
        left transform: (consuming Left) throws(E) -> NewLeft
    ) throws(E) -> Either<NewLeft, Right> {
        switch consume either {
        case .left(let left):
            try .left(transform(consume left))

        case .right(let right):
            .right(consume right)
        }
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable {

    @inlinable
    public static func map<
        NewLeft: ~Copyable,
        NewRight: ~Copyable,
        E: Swift.Error
    >(
        _ either: consuming Either,
        left leftTransform: (consuming Left) throws(E) -> NewLeft,
        right rightTransform: (consuming Right) throws(E) -> NewRight
    ) throws(E) -> Either<NewLeft, NewRight> {
        switch consume either {
        case .left(let left):
            try .left(leftTransform(consume left))

        case .right(let right):
            try .right(rightTransform(consume right))
        }
    }
}

extension Either where Left == Right, Left: ~Copyable {

    @inlinable
    public static func map<NewBoth: ~Copyable, E: Swift.Error>(
        _ either: consuming Either,
        _ transform: (consuming Left) throws(E) -> NewBoth
    ) throws(E) -> Either<NewBoth, NewBoth> {
        switch consume either {
        case .left(let value):
            try .left(transform(consume value))

        case .right(let value):
            try .right(transform(consume value))
        }
    }
}

extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable {

    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewRight: ~Copyable, E: Swift.Error>(
        right transform: (consuming Right) throws(E) -> NewRight
    ) throws(E) -> Either<Left, NewRight> {
        try Self.map(self, right: transform)
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable & ~Escapable {

    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewLeft: ~Copyable, E: Swift.Error>(
        left transform: (consuming Left) throws(E) -> NewLeft
    ) throws(E) -> Either<NewLeft, Right> {
        try Self.map(self, left: transform)
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable {

    @inlinable
    public consuming func map<
        NewLeft: ~Copyable,
        NewRight: ~Copyable,
        E: Swift.Error
    >(
        left leftTransform: (consuming Left) throws(E) -> NewLeft,
        right rightTransform: (consuming Right) throws(E) -> NewRight
    ) throws(E) -> Either<NewLeft, NewRight> {
        try Self.map(self, left: leftTransform, right: rightTransform)
    }
}

extension Either where Left == Right, Left: ~Copyable {

    @inlinable
    public consuming func map<NewBoth: ~Copyable, E: Swift.Error>(
        _ transform: (consuming Left) throws(E) -> NewBoth
    ) throws(E) -> Either<NewBoth, NewBoth> {
        try Self.map(self, transform)
    }
}
