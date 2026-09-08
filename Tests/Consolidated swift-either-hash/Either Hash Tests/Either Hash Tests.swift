import Either
import Equation
import Hash
import Testing

@Suite
struct `Either Hash Tests` {

    @Test
    func `Either supplies Hash's domain-typed value`() {
        let first: Either<Left, Right> = .left(Left())
        let second: Either<Left, Right> = .left(Left())

        let firstHash: Hash.Value = hash(first)
        let secondHash: Hash.Value = hash(second)
        #expect(firstHash == secondHash)
    }

    @Test
    func `Either is natively hashable through the seam`() {
        let left: Either<Left, Right> = .left(Left())
        let equal: Either<Left, Right> = .left(Left())
        let right: Either<Left, Right> = .right(Right())

        let values: Set<Either<Left, Right>> = [left, equal, right]
        #expect(values.count == 2)
    }
}

private struct Left: Hash.`Protocol` {}
private struct Right: Hash.`Protocol` {}

private func hash<T: Hash.`Protocol`>(_ value: borrowing T) -> Hash.Value {
    value.hashValue
}
