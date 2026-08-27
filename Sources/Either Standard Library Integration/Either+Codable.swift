public import Either

#if !hasFeature(Embedded)
    extension Either: Codable where Left: Codable, Right: Codable {
        private enum CodingKeys: String, CodingKey {
            case left
            case right
        }

        private enum AssociatedValueCodingKeys: String, CodingKey {
            case _0
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var allKeys = ArraySlice(container.allKeys)
            guard let onlyKey = allKeys.popFirst(), allKeys.isEmpty else {
                throw DecodingError.typeMismatch(
                    Either<Left, Right>.self,
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid number of keys found, expected one."
                    )
                )
            }
            switch onlyKey {
            case .left:
                let nested = try container.nestedContainer(
                    keyedBy: AssociatedValueCodingKeys.self,
                    forKey: .left
                )
                self = .left(try nested.decode(Left.self, forKey: ._0))
            case .right:
                let nested = try container.nestedContainer(
                    keyedBy: AssociatedValueCodingKeys.self,
                    forKey: .right
                )
                self = .right(try nested.decode(Right.self, forKey: ._0))
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .left(let left):
                var nested = container.nestedContainer(
                    keyedBy: AssociatedValueCodingKeys.self,
                    forKey: .left
                )
                try nested.encode(left, forKey: ._0)
            case .right(let right):
                var nested = container.nestedContainer(
                    keyedBy: AssociatedValueCodingKeys.self,
                    forKey: .right
                )
                try nested.encode(right, forKey: ._0)
            }
        }
    }
#endif
