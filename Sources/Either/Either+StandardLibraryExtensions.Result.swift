@_exported public import Standard_Library_Extensions

extension Either where Left: Swift.Error, Right: ~Copyable {

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
