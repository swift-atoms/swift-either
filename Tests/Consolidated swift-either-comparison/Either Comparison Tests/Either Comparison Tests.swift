import Comparison
import Either
import Testing

private typealias Value = Either<Int, Int>

private func acceptsComparison<Value: Comparison.`Protocol`>(_: Value) {}

@Suite
struct `Either Comparison Tests` {

    @Test func `same-side values use their native equality`() {
        #expect(Value.left(1) == .left(1))
        #expect(Value.left(1) != .left(2))
        #expect(Value.right(1) == .right(1))
        #expect(Value.right(1) != .right(2))
    }

    @Test func `opposite sides are never equal`() {
        #expect(Value.left(1) != .right(1))
        #expect(Value.right(1) != .left(1))
    }

    @Test func `same-side values use their native ordering`() {
        #expect(Value.left(1) < .left(2))
        #expect(Value.right(1) < .right(2))
    }

    @Test func `every left value sorts before every right value`() {
        #expect(Value.left(100) < .right(-100))
        #expect(!(Value.right(-100) < .left(100)))
    }

    @Test func `sorting groups and orders both sides`() {
        let values: [Value] = [.right(2), .left(3), .right(1), .left(1)]
        #expect(values.sorted() == [.left(1), .left(3), .right(1), .right(2)])
    }

    @Test func `conditional conformance satisfies Comparison Protocol`() {
        acceptsComparison(Value.left(1))
        acceptsComparison(Value.right(1))
    }
}
