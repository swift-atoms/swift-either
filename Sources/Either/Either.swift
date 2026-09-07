@_exported public import Comparison
@_exported public import Equation
@_exported public import Hash

@frozen
public enum Either<Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable>: ~Copyable,
    ~Escapable
{

    case left(Left)

    case right(Right)
}

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
