@frozen
public enum Either<Left: ~Copyable & ~Escapable, Right: ~Copyable & ~Escapable>: ~Copyable, ~Escapable
{

    case left(Left)

    case right(Right)
}

extension Either: Swift.Copyable where Left: Swift.Copyable & ~Escapable, Right: Swift.Copyable & ~Escapable {}

extension Either: Swift.Escapable where Left: Swift.Escapable & ~Copyable, Right: Swift.Escapable & ~Copyable {}

extension Either: Swift.Sendable
where
    Left: Swift.Sendable & ~Copyable & ~Escapable,
    Right: Swift.Sendable & ~Copyable & ~Escapable
{}

#if !hasFeature(Embedded)
extension Either: Swift.Codable where Left: Swift.Codable, Right: Swift.Codable {}
#endif
