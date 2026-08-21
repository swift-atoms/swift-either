extension Either where Left: ~Copyable, Right: ~Copyable {

    @inlinable
    public static func flatMap<NewRight: ~Copyable, E: Swift.Error>(
        _ either: consuming Either,
        right transform: (consuming Right) throws(E) -> Either<Left, NewRight>
    ) throws(E) -> Either<Left, NewRight> {
        switch consume either {
        case .left(let left):
            .left(consume left)

        case .right(let right):
            try transform(consume right)
        }
    }

    @inlinable
    public static func flatMap<NewLeft: ~Copyable, E: Swift.Error>(
        _ either: consuming Either,
        left transform: (consuming Left) throws(E) -> Either<NewLeft, Right>
    ) throws(E) -> Either<NewLeft, Right> {
        switch consume either {
        case .left(let left):
            try transform(consume left)

        case .right(let right):
            .right(consume right)
        }
    }
}

extension Either where Left == Right, Left: ~Copyable {

    @inlinable
    public static func flatMap<NewBoth: ~Copyable, E: Swift.Error>(
        _ either: consuming Either,
        _ transform: (consuming Left) throws(E) -> Either<NewBoth, NewBoth>
    ) throws(E) -> Either<NewBoth, NewBoth> {
        switch consume either {
        case .left(let value):
            try transform(consume value)

        case .right(let value):
            try transform(consume value)
        }
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable {

    @inlinable
    public consuming func flatMap<NewRight: ~Copyable, E: Swift.Error>(
        right transform: (consuming Right) throws(E) -> Either<Left, NewRight>
    ) throws(E) -> Either<Left, NewRight> {
        try Self.flatMap(self, right: transform)
    }

    @inlinable
    public consuming func flatMap<NewLeft: ~Copyable, E: Swift.Error>(
        left transform: (consuming Left) throws(E) -> Either<NewLeft, Right>
    ) throws(E) -> Either<NewLeft, Right> {
        try Self.flatMap(self, left: transform)
    }
}

extension Either where Left == Right, Left: ~Copyable {

    @inlinable
    public consuming func flatMap<NewBoth: ~Copyable, E: Swift.Error>(
        _ transform: (consuming Left) throws(E) -> Either<NewBoth, NewBoth>
    ) throws(E) -> Either<NewBoth, NewBoth> {
        try Self.flatMap(self, transform)
    }
}
