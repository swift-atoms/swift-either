// Either+Accessors.swift
// Case-name accessors — return the held value or `nil`.
// The names mirror the case names directly per [API-NAME-002].
//
// Two extensions provide the accessors:
//
// - The default (Copyable + Escapable) form returns `Left?` / `Right?` by
//   value-copy out of the case payload.
// - The `Copyable & ~Escapable` form returns the same shape with
//   `@_lifetime(borrow self)` — the optional carries the same lifetime
//   as the borrowed receiver.
//
// `~Copyable` arms have no accessor in either form: pattern-binding the
// case payload would consume self under a borrow. The free functions
// `value(of:)` (in `Either+Never.swift`) cover the single-arm-uninhabited
// extraction case for `~Copyable & ~Escapable` arms; broader peek
// accessors for `~Copyable` arms are deferred pending SE-0519
// (`Borrow<T>`) per `swift-institute/Research/noncopyable-peek-escapable.md`.

extension Either {

    /// The left value, or `nil` if this is a right.
    @inlinable
    public var left: Left? {
        switch self {
        case .left(let left): left
        case .right: nil
        }
    }

    /// The right value, or `nil` if this is a left.
    @inlinable
    public var right: Right? {
        switch self {
        case .left: nil
        case .right(let right): right
        }
    }
}

// MARK: - Accessors for Copyable & ~Escapable arms

extension Either where Left: Copyable & ~Escapable {

    /// The left value, or `nil` if this is a right.
    ///
    /// Lifetime tied to `self`.
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

    /// The right value, or `nil` if this is a left.
    ///
    /// Lifetime tied to `self`.
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
