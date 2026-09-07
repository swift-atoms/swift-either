@_exported public import Comparison
@_exported public import Equation
@_exported public import Hash

extension Either: Swift.BitwiseCopyable where Left: Swift.BitwiseCopyable, Right: Swift.BitwiseCopyable {}
