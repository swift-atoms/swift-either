extension Either {

    @inlinable
    public var left: Left? {
        switch self {
        case .left(let left): left
        case .right: nil
        }
    }

    @inlinable
    public var right: Right? {
        switch self {
        case .left: nil
        case .right(let right): right
        }
    }
}

extension Either where Left: Copyable & ~Escapable {

    @inlinable
    public var left: Left? {
        @_lifetime(borrow self)
        get {
            switch self {
            case .left(let left): return left
            case .right: return nil
            }
        }
    }
}

extension Either where Right: Copyable & ~Escapable {

    @inlinable
    public var right: Right? {
        @_lifetime(borrow self)
        get {
            switch self {
            case .left: return nil
            case .right(let right): return right
            }
        }
    }
}
