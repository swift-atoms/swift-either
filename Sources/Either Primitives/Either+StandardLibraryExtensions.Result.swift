// Either+StandardLibraryExtensions.Result.swift
// Interop with the institute's ~Copyable-aware Result.
//
// `Standard_Library_Extensions.Result<Success, Failure>` is the institute's
// drop-in for `Swift.Result` that admits `Success: ~Copyable`. This file
// supplies a one-direction interop init: `Either(_ result: SLE.Result<...>)`,
// projecting `.failure` to `.left` and `.success` to `.right`.
//
// The reverse direction (`SLE.Result.init(_ either:)`) is intentionally
// omitted: it would require extending another package's type, and consumers
// can write the equivalent fold in one line:
//
//     either.fold(
//         left:  { .failure($0) },
//         right: { .success($0) }
//     )
//
// No analogous init for `Swift.Result` is provided in this package — the
// interop point is the SLE Result. Consumers holding a stdlib Result can
// fold on the institute side or migrate to SLE Result.
//
// The init is `consuming` on its argument and admits `Right: ~Copyable`.
// `Left: Swift.Error` is the constraint required by SLE Result's `Failure`
// associated type.

@_exported public import Standard_Library_Extensions

extension Either where Left: Swift.Error, Right: ~Copyable {

    /// Creates an `Either` by projecting the institute's ~Copyable-aware
    /// `Result` into the binary coproduct: `.failure` becomes `.left`,
    /// `.success` becomes `.right`.
    ///
    /// `Right` may be `~Copyable`; the SLE `Result` is consumed in that case.
    /// `Left` is constrained to `Swift.Error` because SLE `Result`'s
    /// `Failure` associated type requires it.
    ///
    /// ```swift
    /// // Copyable success
    /// let r1: Standard_Library_Extensions.Result<Int, MyError> = .success(42)
    /// let e1 = Either(r1)                  // Either<MyError, Int>.right(42)
    ///
    /// // ~Copyable success
    /// let r2: Standard_Library_Extensions.Result<Resource, MyError> = .success(Resource())
    /// let e2 = Either(r2)                  // moves the resource into .right
    /// ```
    @inlinable
    public init(_ result: consuming Standard_Library_Extensions.Result<Right, Left>) {
        switch consume result {
        case .success(let value):
            self = .right(consume value)

        case .failure(let error):
            self = .left(error)
        }
    }
}
