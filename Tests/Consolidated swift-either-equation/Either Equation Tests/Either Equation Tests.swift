import Either
import Equation
import Testing

@Suite
struct `Either Equation Tests` {
    @Test
    func `Either conditionally satisfies Equation Protocol`() {
        func acceptsEquationProtocol<T: Equation.`Protocol`>(_ value: T) -> T {
            value
        }

        let value: Either<String, Int> = .left("value")
        #expect(acceptsEquationProtocol(value) == value)
    }

    @Test
    func `Matching arms compare their payloads`() {
        let first: Either<String, Int> = .right(3)
        let second: Either<String, Int> = .right(3)
        let different: Either<String, Int> = .right(4)

        #expect(first == second)
        #expect(first != different)
    }

    @Test
    func `Different arms compare unequal`() {
        let left: Either<Int, Int> = .left(3)
        let right: Either<Int, Int> = .right(3)

        #expect(left != right)
    }
}
