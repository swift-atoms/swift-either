// Either+Fold.swift
// Catamorphism — eliminates the `Either` by handling both cases.
// The universal property of the coproduct.
//
// The static layer is the canonical implementation; the instance method is a
// thin delegate. Variants are `consuming` and apply on `where Left:
// ~Copyable, Right: ~Copyable`. They subsume both Copyable and `~Copyable`
// arms — for Copyable arms, Swift's ownership system implicitly inserts copies.

// MARK: - Static layer (canonical implementation)

extension Either where Left: ~Copyable, Right: ~Copyable {

    /// Eliminates the `Either` by handling both cases, consuming `either`.
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

// MARK: - Instance layer (delegates to static)

extension Either where Left: ~Copyable, Right: ~Copyable {

    /// Eliminates the `Either` by handling both cases, consuming `self`.
    @inlinable
    public consuming func fold<Result: ~Copyable, E: Swift.Error>(
        left leftHandler: (consuming Left) throws(E) -> Result,
        right rightHandler: (consuming Right) throws(E) -> Result
    ) throws(E) -> Result {
        try Self.fold(self, left: leftHandler, right: rightHandler)
    }
}

// fold is Escapable-only on both arms because both closures consume their arms
// and produce `Result`. The Result's lifetime is whatever `leftHandler` /
// `rightHandler` decides, which is independent of `either` — same Gap A
// limitation that constrains flatMap.
