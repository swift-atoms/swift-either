// Either+Swap.swift
// Component swap — exchanges Left and Right.
//
// The static layer is the canonical implementation; the instance method is a
// thin delegate. Variants are `consuming` and apply on `where Left:
// ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable`. They subsume
// Copyable + Escapable, ~Copyable + Escapable, ~Copyable + ~Escapable, and
// Copyable + ~Escapable arms — for Copyable arms Swift's ownership system
// implicitly inserts copies; the `@_lifetime(copy either)` annotation
// anchors the result's lifetime to the consumed input for ~Escapable arms.

// MARK: - Static layer (canonical implementation)

extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable {

    /// Returns the either with components swapped, consuming `either`.
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

// MARK: - Instance layer (delegates to static)

extension Either where Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable {

    /// Returns the either with components swapped, consuming `self`.
    @inlinable
    @_lifetime(copy self)
    public consuming func swapped() -> Either<Right, Left> {
        Self.swapped(self)
    }
}
