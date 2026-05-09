// Either+FlatMap.swift
// Monadic bind — chains an Either-returning operation while preserving the
// fixed arm's type. Right-biased and left-biased forms are provided
// symmetrically per [API-NAME-002] (no compound names) and [API-NAME-008]
// (single verb parameterized by argument label).
//
// The static layer is the canonical implementation; instance methods are
// thin delegates. All variants are `consuming` and apply on `where Left:
// ~Copyable, Right: ~Copyable`. They subsume both Copyable and `~Copyable`
// arms — for Copyable arms, Swift's ownership system implicitly inserts copies.
//
// `flatMap(right:)` and `flatMap(left:)` are deliberately ambiguous when
// called with a trailing closure — consumers MUST use the explicit
// `flatMap(right: { … })` or `flatMap(left: { … })` form. The unlabeled
// trailing-closure form is reserved for the `Left == Right` equal-arm
// convenience.
// swift-format-ignore-file: AmbiguousTrailingClosureOverload

// MARK: - Static layer (canonical implementations)
//
// flatMap's `~Escapable` story is asymmetric vs map: the closure returns a
// new Either whose lifetime is independent of the input. Adding
// `@_lifetime(copy either)` would lie about the right-case branch (result
// from `transform`, not from `either`). flatMap therefore stays Escapable-
// only on both arms — closure-bearing methods generally need Gap A
// resolution before admitting ~Escapable.

extension Either where Left: ~Copyable, Right: ~Copyable {

    /// Chains an Either-returning operation on the right arm, consuming `either`.
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

    /// Chains an Either-returning operation on the left arm, consuming `either`.
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

// MARK: - Equal-arm convenience (canonical static)

extension Either where Left == Right, Left: ~Copyable {

    /// Chains an Either-returning operation when the arms share a type,
    /// consuming `either`.
    ///
    /// ```swift
    /// let either: Either<Int, Int> = .right(7)
    /// let chained = Either.flatMap(either) { value -> Either<String, String> in
    ///     value > 0 ? .right("positive") : .left("non-positive")
    /// }
    /// ```
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

// MARK: - Instance layer (delegates to static)

extension Either where Left: ~Copyable, Right: ~Copyable {

    /// Chains an Either-returning operation on the right arm, consuming `self`.
    @inlinable
    public consuming func flatMap<NewRight: ~Copyable, E: Swift.Error>(
        right transform: (consuming Right) throws(E) -> Either<Left, NewRight>
    ) throws(E) -> Either<Left, NewRight> {
        try Self.flatMap(self, right: transform)
    }

    /// Chains an Either-returning operation on the left arm, consuming `self`.
    @inlinable
    public consuming func flatMap<NewLeft: ~Copyable, E: Swift.Error>(
        left transform: (consuming Left) throws(E) -> Either<NewLeft, Right>
    ) throws(E) -> Either<NewLeft, Right> {
        try Self.flatMap(self, left: transform)
    }
}

// MARK: - Equal-arm convenience (instance delegates to static)

extension Either where Left == Right, Left: ~Copyable {

    /// Chains an Either-returning operation when the arms share a type,
    /// consuming `self`.
    @inlinable
    public consuming func flatMap<NewBoth: ~Copyable, E: Swift.Error>(
        _ transform: (consuming Left) throws(E) -> Either<NewBoth, NewBoth>
    ) throws(E) -> Either<NewBoth, NewBoth> {
        try Self.flatMap(self, transform)
    }
}
