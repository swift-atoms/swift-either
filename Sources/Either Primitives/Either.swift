// Either.swift
// The binary coproduct type.
//
// Conditional conformances live in this file because Swift requires
// conformance synthesis (`==`, `hash(into:)`, `init(from:)`, `encode(to:)`,
// implicit `Sendable` / `Escapable` checking) to occur in the same source
// file as the generic enum's declaration. Stdlib `Result.swift` follows the
// same pattern.

@_exported public import Comparison_Primitives
@_exported public import Equation_Primitives
@_exported public import Hash_Primitives

/// A value of one of two types — the binary coproduct.
///
/// `Either<Left, Right>` represents the categorical coproduct `Left + Right`,
/// the dual of a binary product (which holds *both* values). `Either` holds
/// *exactly one*.
///
/// Use `Either` for typed disjoint alternatives that carry their own value —
/// classifier-tagged outputs, parser results, dual-path state, and any place
/// where one of two unrelated types is the right answer. For the
/// error-channel variant where one side is privileged as "the failure", the
/// standard library's `Result<T, E>` is the right tool.
///
/// SE-0413 (Typed Throws) reaches for an `Either` shape pedagogically
/// when discussing how `throws(some Error)` could combine multiple thrown
/// types under the hood; the proposal does not require it as an
/// implementation. This type is the public realisation for cases where a
/// typed sum is what you want.
///
/// ## Example
///
/// ```swift
/// let success: Either<String, Int> = .right(42)
/// let failure: Either<String, Int> = .left("not found")
///
/// let doubled = success.map(right: { $0 * 2 })   // .right(84)
/// let flipped = success.swapped()                 // Either<Int, String>.left(42)
/// ```
///
/// `Never` on either side eliminates the case unconditionally:
///
/// ```swift
/// let certain: Either<Never, Int> = .right(10)
/// print(certain.value)  // 10 — left side is uninhabited
/// ```
///
/// ## Type-level constraints
///
/// `Either` suppresses `Copyable` and `Escapable` on both type parameters:
///
/// ```swift
/// public enum Either<Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable>
/// ```
///
/// This means `Either` can hold non-copyable resources or non-escapable views
/// in either arm. The conformance ladder mirrors stdlib `Result.swift`:
///
/// | Conformance              | Constraint                                                                           |
/// |--------------------------|--------------------------------------------------------------------------------------|
/// | `Copyable`               | `Left, Right: Copyable & ~Escapable`                                                 |
/// | `Escapable`              | `Left, Right: Escapable & ~Copyable`                                                 |
/// | `Sendable`               | `Left, Right: Sendable & ~Copyable & ~Escapable` (independent of copyability)        |
/// | `BitwiseCopyable`        | `Left, Right: BitwiseCopyable`                                                       |
/// | `Equatable`              | `Left, Right: Equatable` (admits `~Copyable` arms on Swift 6.4+ via SE-0499)        |
/// | `Hashable`               | `Left, Right: Hashable` (admits `~Copyable` arms on Swift 6.4+ via SE-0499)         |
/// | `Codable`                | `Left, Right: Codable` (gated on `!hasFeature(Embedded)`)                            |
/// | `Swift.Error`            | `Left, Right: Swift.Error`                                                           |
/// | `Equation.Protocol`      | `Left, Right: Equation.Protocol & ~Copyable` (institute Equatable; collapses to `Swift.Equatable` on Swift 6.4+ via SE-0499) |
/// | `Hash.Protocol`          | `Left, Right: Hash.Protocol & ~Copyable` (institute Hashable; collapses to `Swift.Hashable` on Swift 6.4+)                  |
/// | `Comparison.Protocol`    | `Left, Right: Comparison.Protocol & ~Copyable` (institute Comparable; collapses to `Swift.Comparable` on Swift 6.4+)        |
///
/// The functor methods (`map`, `fold`, `swapped`, `flatMap`) currently require
/// `Copyable & Escapable` arms — the standard case. Forward-compatible
/// `consuming` variants for `~Copyable` arms are tracked in
/// `Experiments/consuming-method-patterns/`.
@frozen
public enum Either<Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable>: ~Copyable,
    ~Escapable
{
    /// The left alternative.
    case left(Left)

    /// The right alternative.
    case right(Right)
}

// MARK: - Conditional conformances

extension Either: Copyable where Left: Copyable & ~Escapable, Right: Copyable & ~Escapable {}

extension Either: Escapable where Left: Escapable & ~Copyable, Right: Escapable & ~Copyable {}

extension Either: Sendable
where
    Left: Sendable & ~Copyable & ~Escapable,
    Right: Sendable & ~Copyable & ~Escapable
{}

extension Either: BitwiseCopyable where Left: BitwiseCopyable, Right: BitwiseCopyable {}

#if !hasFeature(Embedded)
    extension Either: Codable where Left: Codable, Right: Codable {}
#endif

extension Either: Swift.Error where Left: Swift.Error, Right: Swift.Error {}
