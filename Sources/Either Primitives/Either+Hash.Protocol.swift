// Either+Hash.Protocol.swift
// Conformance of Either to Hash.Protocol — unconditional.

extension Either: Swift.Hashable
where
    Left: Hash.`Protocol` & ~Copyable,
    Right: Hash.`Protocol` & ~Copyable
{
    /// Hashes the essential components of this either value into the given hasher.
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        switch self {
        case .left(let left):
            hasher.combine(0 as UInt8)
            left.hash(into: &hasher)

        case .right(let right):
            hasher.combine(1 as UInt8)
            right.hash(into: &hasher)
        }
    }
}

extension Either: Hash.`Protocol`
where
    Left: Hash.`Protocol` & ~Copyable,
    Right: Hash.`Protocol` & ~Copyable
{}
