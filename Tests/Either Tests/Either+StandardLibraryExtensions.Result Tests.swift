import Either
import Standard_Library_Extensions
import Testing

@Suite
struct `Either StandardLibraryExtensions Result Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Either StandardLibraryExtensions Result Tests`.Unit {
    @Suite struct `Copyable Success` {}
    @Suite struct `Noncopyable Success` {}
}

private struct InteropError: Swift.Error, Equatable {
    let code: Int
}

private struct InteropResource: ~Copyable {
    let id: Int
    init(_ id: Int) { self.id = id }
}

extension `Either StandardLibraryExtensions Result Tests`.Unit.`Copyable Success` {

    @Test
    func `Result.success projects to Either.right`() {
        let result: Standard_Library_Extensions.Result<Int, InteropError> = .success(42)
        let either = Either(result)
        guard case .right(let value) = either else {
            Issue.record("expected .right after converting .success")
            return
        }
        #expect(value == 42)
    }

    @Test
    func `Result.failure projects to Either.left`() {
        let error = InteropError(code: 7)
        let result: Standard_Library_Extensions.Result<Int, InteropError> = .failure(error)
        let either = Either(result)
        guard case .left(let extracted) = either else {
            Issue.record("expected .left after converting .failure")
            return
        }
        #expect(extracted == error)
    }

    @Test
    func `round-trip via fold reproduces the original Result`() {
        let original: Standard_Library_Extensions.Result<String, InteropError> = .success("ok")
        let either = Either(original)
        let roundTripped: Standard_Library_Extensions.Result<String, InteropError> =
            either.fold(
                left: { Standard_Library_Extensions.Result<String, InteropError>.failure($0) },
                right: { Standard_Library_Extensions.Result<String, InteropError>.success($0) }
            )
        guard case .success(let value) = roundTripped else {
            Issue.record("expected .success after round-trip")
            return
        }
        #expect(value == "ok")
    }

    @Test
    func `failure round-trip via fold preserves the error`() {
        let error = InteropError(code: 99)
        let original: Standard_Library_Extensions.Result<String, InteropError> = .failure(error)
        let either = Either(original)
        let roundTripped: Standard_Library_Extensions.Result<String, InteropError> =
            either.fold(
                left: { Standard_Library_Extensions.Result<String, InteropError>.failure($0) },
                right: { Standard_Library_Extensions.Result<String, InteropError>.success($0) }
            )
        guard case .failure(let extracted) = roundTripped else {
            Issue.record("expected .failure after round-trip")
            return
        }
        #expect(extracted == error)
    }

    @Test
    func `Either(SLE.Result) is usable as a Swift_Error coproduct`() {
        struct Fault: Swift.Error, Equatable {}

        let result: Standard_Library_Extensions.Result<Fault, InteropError> =
            .failure(InteropError(code: 3))
        let either: Either<InteropError, Fault> = Either(result)
        guard case .left(let err) = either else {
            Issue.record("expected .left from upstream failure")
            return
        }
        #expect(err.code == 3)

        func throwIt(_ e: Either<InteropError, Fault>) throws(Either<InteropError, Fault>) {
            throw e
        }
        do throws(Either<InteropError, Fault>) {
            try throwIt(either)
            Issue.record("expected throw")
        } catch {
            guard case .left(let err) = error else {
                Issue.record("expected .left after throw")
                return
            }
            #expect(err.code == 3)
        }
    }
}

extension `Either StandardLibraryExtensions Result Tests`.Unit.`Noncopyable Success` {

    @Test
    func `Result.success with ~Copyable Success projects to Either.right`() {
        let result: Standard_Library_Extensions.Result<InteropResource, InteropError> =
            .success(InteropResource(13))
        let either = Either(result)
        guard case .right(let resource) = either else {
            Issue.record("expected .right after converting ~Copyable .success")
            return
        }
        #expect(resource.id == 13)
    }

    @Test
    func `Result.failure with ~Copyable Success projects to Either.left`() {
        let error = InteropError(code: 21)
        let result: Standard_Library_Extensions.Result<InteropResource, InteropError> =
            .failure(error)
        let either = Either(result)
        guard case .left(let extracted) = either else {
            Issue.record("expected .left after converting ~Copyable .failure")
            return
        }
        #expect(extracted == error)
    }
}
