@_exported public import Comparison
@_exported public import Equation
@_exported public import Hash

extension Either: Swift.Error where Left: Swift.Error, Right: Swift.Error {}
