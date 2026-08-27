public import Either

#if !hasFeature(Embedded)
    extension Either: Codable where Left: Codable, Right: Codable {}
#endif
