// Either+Never.swift
// Never elimination — unconditional extraction when one side is uninhabited.
// SE-0413 §"Alternatives Considered" anticipates an `Uninhabited` protocol
// that would generalise this; until that lands, the explicit `where == Never`
// form is the canonical mechanism.
//
// Two access paths are provided:
//
// - **Property form** (`e.value`) — multi-read accessor on Copyable arms.
//   Implicit `Copyable & Escapable` from the extension's where-clause defaults
//   restricts this to Copyable + Escapable arms.
//
// - **Free-function form** (`value(of: e)`) — single-consume extraction that
//   admits `~Copyable & ~Escapable` arms. Consumes `e`. Mirrors the
//   `swapped(_:)` precedent on `swift-product-primitives` for arity-2 cases
//   where a property-syntax accessor is blocked by Swift compiler limitations
//   (see `swift-institute/Research/noncopyable-property-extract-via-underscore-owned.md`).
//   When Swift ships stable `consuming get` accessor support that admits
//   the generic `~Copyable` enum case, an `@_owned` property variant will
//   replace the free function for newer toolchains.

// MARK: - Property form (Copyable arms)

extension Either where Left == Never {

    /// The right value, extractable unconditionally because the left is uninhabited.
    @inlinable
    public var value: Right {
        switch self {
        case .right(let right): right
        }
    }
}

extension Either where Right == Never {

    /// The left value, extractable unconditionally because the right is uninhabited.
    @inlinable
    public var value: Left {
        switch self {
        case .left(let left): left
        }
    }
}

// MARK: - Free-function form (admits ~Copyable & ~Escapable arms)

/// Extracts the inhabited value from an `Either<Never, Right>`, consuming `either`.
///
/// Admits `~Copyable & ~Escapable` arms — call this when the property-syntax
/// `either.value` accessor doesn't apply because `Right` is `~Copyable`.
///
/// ```swift
/// // Copyable case — property and free-function both work
/// let e1: Either<Never, Int> = .right(42)
/// let v1 = e1.value         // property form, multi-read
/// let v2 = value(of: e1)    // free-function form, consumes e1
///
/// // ~Copyable case — only the free-function form compiles
/// struct Resource: ~Copyable { let id: Int }
/// let e2: Either<Never, Resource> = .right(Resource(id: 7))
/// let v3 = value(of: e2)    // moves the resource out of e2
///
/// // ~Escapable case — admitted; result lifetime tied to either
/// struct NEResource: ~Escapable { ... }
/// let e3: Either<Never, NEResource> = .right(...)
/// let v4 = value(of: e3)    // moves the ~Escapable resource out
/// ```
@inlinable
@_lifetime(copy either)
public func value<Right: ~Copyable & ~Escapable>(
    of either: consuming Either<Never, Right>
) -> Right {
    switch consume either {
    case .right(let right): right
    }
}

/// Extracts the inhabited value from an `Either<Left, Never>`, consuming `either`.
///
/// Admits `~Copyable & ~Escapable` arms.
@inlinable
@_lifetime(copy either)
public func value<Left: ~Copyable & ~Escapable>(
    of either: consuming Either<Left, Never>
) -> Left {
    switch consume either {
    case .left(let left): left
    }
}
