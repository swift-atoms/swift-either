extension Either: Hash::Hash.`Protocol`
where
    Left: Hash::Hash.`Protocol` & ~Copyable,
    Right: Hash::Hash.`Protocol` & ~Copyable
{}
