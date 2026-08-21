extension Either where Left: ~Copyable, Right: ~Copyable {

    @inlinable
    public static func fold<Result: ~Copyable, E: Swift.Error>(
        _ either: consuming Either,
        left leftHandler: (consuming Left) throws(E) -> Result,
        right rightHandler: (consuming Right) throws(E) -> Result
    ) throws(E) -> Result {
        switch consume either {
        case .left(let left):
            try leftHandler(consume left)

        case .right(let right):
            try rightHandler(consume right)
        }
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable {

    @inlinable
    public consuming func fold<Result: ~Copyable, E: Swift.Error>(
        left leftHandler: (consuming Left) throws(E) -> Result,
        right rightHandler: (consuming Right) throws(E) -> Result
    ) throws(E) -> Result {
        try Self.fold(self, left: leftHandler, right: rightHandler)
    }
}
