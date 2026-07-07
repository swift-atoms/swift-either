// Either+Equation.Protocol.swift
// Conformance of Either to Equation.Protocol — unconditional.
//
// On Swift <6.4, `Equation.Protocol` is the institute fork supporting
// `borrowing` parameters for `~Copyable` arms. On Swift 6.4+, it is a
// typealias to `Swift.Equatable` per SE-0499 — this same extension then
// satisfies the stdlib conformance directly. The stdlib `extension Either:
// Equatable where Left: Equatable, Right: Equatable {}` in `Either.swift`
// is therefore guarded `#if swift(<6.4)` to avoid duplicate-conformance.

#if swift(<6.4)
    extension Either: Equation.`Protocol`
    where
        Left: Equation.`Protocol` & ~Copyable & ~Escapable,
        Right: Equation.`Protocol` & ~Copyable & ~Escapable
    {
        /// Returns whether two `Either` values are equal.
        ///
        /// Two `.left` values are equal if their payloads compare equal under
        /// `Equation.Protocol`. Two `.right` values are equal if their payloads
        /// compare equal. A `.left` and `.right` are never equal.
        ///
        /// - Note: Uses `@_disfavoredOverload` so the stdlib `Swift.Equatable`
        ///   synthesized conformance is preferred for Copyable arms on Swift
        ///   <6.4; the move-only borrowing path is selected when at least one
        ///   arm is `~Copyable`.
        @inlinable
        @_disfavoredOverload
        public static func == (lhs: borrowing Either, rhs: borrowing Either) -> Bool {
            switch lhs {
            case .left(let lLeft):
                switch rhs {
                case .left(let rLeft):
                    return lLeft == rLeft

                case .right:
                    return false
                }

            case .right(let lRight):
                switch rhs {
                case .left:
                    return false

                case .right(let rRight):
                    return lRight == rRight
                }
            }
        }
    }
#else
    // Swift 6.4+: Equation.Protocol = Swift.Equatable. Drops ~Escapable arm.
    extension Either: Equation.`Protocol`
    where
        Left: Equation.`Protocol` & ~Copyable,
        Right: Equation.`Protocol` & ~Copyable
    {
        /// Returns whether two `Either` values are equal, comparing payloads only within a matching case.
        @inlinable
        @_disfavoredOverload
        public static func == (lhs: borrowing Either, rhs: borrowing Either) -> Bool {
            switch lhs {
            case .left(let lLeft):
                switch rhs {
                case .left(let rLeft):
                    return lLeft == rLeft

                case .right:
                    return false
                }

            case .right(let lRight):
                switch rhs {
                case .left:
                    return false

                case .right(let rRight):
                    return lRight == rRight
                }
            }
        }
    }
#endif
