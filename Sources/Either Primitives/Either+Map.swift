// Either+Map.swift
// Functor surface — labeled-overload form per [API-NAME-002] and [API-NAME-008].
// Replaces compound `mapLeft` / `mapRight` / `bimap` with a single `map` verb
// disambiguated by `left:` / `right:` argument labels.
//
// The static layer is the canonical implementation; instance methods are thin
// delegates. All variants are `consuming` and apply on `where Left: ~Copyable,
// Right: ~Copyable`. They subsume both Copyable and `~Copyable` arms — for
// Copyable arms, Swift's ownership system implicitly inserts copies, so
// closure shapes like `{ $0 * 2 }` convert transparently to
// `(consuming Right) -> NewRight`.
//
// `map(right:)` and `map(left:)` are deliberately ambiguous when called with
// a trailing closure (`either.map { … }`) — consumers MUST use the explicit
// `map(right: { … })` or `map(left: { … })` form. The unlabeled trailing-
// closure form is reserved for the `Left == Right` equal-arm convenience.
// swift-format-ignore-file: AmbiguousTrailingClosureOverload

// MARK: - Static layer (canonical implementations)
//
// Constraints: the un-transformed arm admits `~Escapable` (passes through
// unchanged); the closure-transformed arm requires `Escapable` because Swift's
// closure-parameter lifetime dependencies (Gap A in
// `nonescapable-ecosystem-state.md` §5) are not yet ready for `~Escapable`
// closure inputs/outputs. Result lifetime is `copy either` — when the
// un-transformed arm is `~Escapable`, the result inherits its lifetime.

extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable {

    /// Transforms the right component while preserving the left, consuming `either`.
    ///
    /// `Left` may be `~Escapable`; `Right` and `NewRight` must be `Escapable`.
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

    /// Transforms the left component while preserving the right, consuming `either`.
    ///
    /// `Right` may be `~Escapable`; `Left` and `NewLeft` must be `Escapable`.
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

    /// Transforms both components, consuming `either`.
    ///
    /// Both arms must be `Escapable` (closure-parameter lifetime dependencies
    /// are not ready for `~Escapable` closure inputs/outputs).
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

// MARK: - Equal-arm convenience (canonical static)

extension Either where Left == Right, Left: ~Copyable {

    /// Transforms both arms with the same closure when the arms share a type,
    /// consuming `either`.
    ///
    /// `Either<T, T>` is a degenerate coproduct: both cases hold the same
    /// type. The unlabeled `map` form lets you apply one transform regardless
    /// of which arm is inhabited, returning the same-arm `Either<NewBoth, NewBoth>`.
    ///
    /// ```swift
    /// let either: Either<Int, Int> = .right(7)
    /// let doubled = Either.map(either) { $0 * 2 }   // .right(14)
    /// ```
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

// MARK: - Instance layer (delegates to static)
//
// Instance overloads mirror the static layer's where-clause shape: the
// un-transformed arm admits `~Escapable`, the transformed arm requires
// Escapable. Result lifetime tied to `self` via `@_lifetime(copy self)`.

extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable {

    /// Transforms the right component while preserving the left, consuming `self`.
    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewRight: ~Copyable, E: Swift.Error>(
        right transform: (consuming Right) throws(E) -> NewRight
    ) throws(E) -> Either<Left, NewRight> {
        try Self.map(self, right: transform)
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable & ~Escapable {

    /// Transforms the left component while preserving the right, consuming `self`.
    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewLeft: ~Copyable, E: Swift.Error>(
        left transform: (consuming Left) throws(E) -> NewLeft
    ) throws(E) -> Either<NewLeft, Right> {
        try Self.map(self, left: transform)
    }
}

extension Either where Left: ~Copyable, Right: ~Copyable {

    /// Transforms both components, consuming `self`.
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

// MARK: - Equal-arm convenience (instance delegates to static)

extension Either where Left == Right, Left: ~Copyable {

    /// Transforms both arms with the same closure when the arms share a type,
    /// consuming `self`.
    @inlinable
    public consuming func map<NewBoth: ~Copyable, E: Swift.Error>(
        _ transform: (consuming Left) throws(E) -> NewBoth
    ) throws(E) -> Either<NewBoth, NewBoth> {
        try Self.map(self, transform)
    }
}
