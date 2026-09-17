import Either
import Testing

@Suite
struct `Either operations preserve the active arm and its payload` {
    @Suite struct `Either construction transformation and conformances preserve arm semantics` {}
    @Suite struct `No Either boundary cases are defined` {}
    @Suite struct `No Either integration cases are defined` {}
    @Suite(.serialized) struct `No Either performance cases are defined` {}
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics` {
    @Suite struct `Either construction retains the selected arm and payload` {}
    @Suite struct `Either mapping transforms selected arms and preserves untouched arms` {}
    @Suite struct `Either flat mapping can change arms and preserves untouched arms` {}
    @Suite struct `Either folding evaluates the active arm` {}
    @Suite struct `Swapping Either exchanges arms and preserves payloads` {}
    @Suite struct `Either accessors return only the active payload` {}
    @Suite struct `Either eliminates impossible arms without losing the remaining payload` {}
    @Suite struct `Either equality hashing and descriptions preserve arm identity` {}
    @Suite struct `Either intrinsic conformances preserve payload and arm semantics` {}
    @Suite struct `Consuming Either operations support noncopyable payloads` {}
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either construction retains the selected arm and payload` {

    @Test
    func `left case stores its payload`() {
        let either: Either<String, Int> = .left("error")
        guard case .left(let value) = either else {
            Issue.record("expected .left")
            return
        }
        #expect(value == "error")
    }

    @Test
    func `right case stores its payload`() {
        let either: Either<String, Int> = .right(42)
        guard case .right(let value) = either else {
            Issue.record("expected .right")
            return
        }
        #expect(value == 42)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either mapping transforms selected arms and preserves untouched arms` {

    @Test
    func `map(right:) preserves left case`() {
        let leftCase: Either<String, Int> = .left("error")
        let mapped = leftCase.map(right: { $0 * 2 })
        guard case .left(let message) = mapped else {
            Issue.record("expected .left to be preserved")
            return
        }
        #expect(message == "error")
    }

    @Test
    func `map(right:) transforms right case`() {
        let rightCase: Either<String, Int> = .right(10)
        let mapped = rightCase.map(right: { $0 * 2 })
        guard case .right(let value) = mapped else {
            Issue.record("expected .right to be preserved")
            return
        }
        #expect(value == 20)
    }

    @Test
    func `map(right:) propagates typed throws`() {
        struct Failure: Swift.Error, Equatable {}
        let rightCase: Either<String, Int> = .right(10)
        do throws(Failure) {
            _ = try rightCase.map(right: { (_: Int) throws(Failure) -> Int in throw Failure() })
            Issue.record("expected throw")
        } catch {
            #expect(error == Failure())
        }
    }

    @Test
    func `map(left:) transforms left case`() {
        let leftCase: Either<String, Int> = .left("err")
        let mapped = leftCase.map(left: { $0.uppercased() })
        guard case .left(let message) = mapped else {
            Issue.record("expected .left")
            return
        }
        #expect(message == "ERR")
    }

    @Test
    func `map(left:) preserves right case`() {
        let rightCase: Either<String, Int> = .right(7)
        let mapped = rightCase.map(left: { $0.uppercased() })
        guard case .right(let value) = mapped else {
            Issue.record("expected .right to be preserved")
            return
        }
        #expect(value == 7)
    }

    @Test
    func `map(left:right:) transforms both arms`() {
        let leftCase: Either<String, Int> = .left("err")
        let rightCase: Either<String, Int> = .right(3)

        let leftMapped = leftCase.map(left: { $0.count }, right: { Double($0) })
        let rightMapped = rightCase.map(left: { $0.count }, right: { Double($0) })

        guard case .left(let l) = leftMapped, case .right(let r) = rightMapped else {
            Issue.record("expected matching arms")
            return
        }
        #expect(l == 3)
        #expect(r == 3.0)
    }

    @Test
    func `static map mirrors instance map`() {
        let either: Either<String, Int> = .right(5)
        let viaInstance = either.map(right: { $0 + 1 })
        let viaStatic = Either<String, Int>.map(either, right: { $0 + 1 })

        #expect(viaInstance == viaStatic)
    }

    @Test
    func `unlabeled map applies one transform when arms share a type (right)`() {
        let either: Either<Int, Int> = .right(7)
        let doubled = either.map { $0 * 2 }
        guard case .right(let value) = doubled else {
            Issue.record("expected .right after equal-arm map")
            return
        }
        #expect(value == 14)
    }

    @Test
    func `unlabeled map applies one transform when arms share a type (left)`() {
        let either: Either<Int, Int> = .left(3)
        let mapped = either.map { $0 + 100 }
        guard case .left(let value) = mapped else {
            Issue.record("expected .left after equal-arm map")
            return
        }
        #expect(value == 103)
    }

    @Test
    func `unlabeled map can change the shared arm type`() {
        let either: Either<Int, Int> = .right(5)
        let mapped: Either<String, String> = either.map { String($0) }
        guard case .right(let value) = mapped else {
            Issue.record("expected .right")
            return
        }
        #expect(value == "5")
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either flat mapping can change arms and preserves untouched arms` {

    @Test
    func `flatMap(right:) preserves left case`() {
        let leftCase: Either<String, Int> = .left("error")
        let chained = leftCase.flatMap(right: { _ in
            Either<String, String>.right("never reached")
        })
        guard case .left(let message) = chained else {
            Issue.record("expected .left to be preserved")
            return
        }
        #expect(message == "error")
    }

    @Test
    func `flatMap(right:) chains right value through transform`() {
        let either: Either<String, Int> = .right(7)
        let chained = either.flatMap(right: { value -> Either<String, String> in
            value > 0 ? .right("positive: \(value)") : .left("non-positive")
        })
        guard case .right(let value) = chained else {
            Issue.record("expected .right after positive transform")
            return
        }
        #expect(value == "positive: 7")
    }

    @Test
    func `flatMap(right:) can collapse to left`() {
        let either: Either<String, Int> = .right(-3)
        let chained = either.flatMap(right: { value -> Either<String, String> in
            value > 0 ? .right("positive") : .left("non-positive: \(value)")
        })
        guard case .left(let message) = chained else {
            Issue.record("expected .left after non-positive transform")
            return
        }
        #expect(message == "non-positive: -3")
    }

    @Test
    func `flatMap(left:) preserves right case`() {
        let either: Either<String, Int> = .right(42)
        let chained = either.flatMap(left: { _ in
            Either<Int, Int>.left(0)
        })
        guard case .right(let value) = chained else {
            Issue.record("expected .right to be preserved")
            return
        }
        #expect(value == 42)
    }

    @Test
    func `flatMap(left:) chains left value through transform`() {
        let either: Either<String, Int> = .left("404")
        let chained = either.flatMap(left: { code -> Either<Int, Int> in
            Int(code).map { .left($0) } ?? .right(0)
        })
        guard case .left(let value) = chained else {
            Issue.record("expected .left after numeric transform")
            return
        }
        #expect(value == 404)
    }

    @Test
    func `flatMap(right:) propagates typed throws`() {
        struct Failure: Swift.Error, Equatable {}
        let either: Either<String, Int> = .right(7)
        do throws(Failure) {
            _ = try either.flatMap(right: { (_: Int) throws(Failure) -> Either<String, Int> in
                throw Failure()
            })
            Issue.record("expected throw")
        } catch {
            #expect(error == Failure())
        }
    }

    @Test
    func `unlabeled flatMap chains when arms share a type`() {
        let either: Either<Int, Int> = .right(5)
        let chained = either.flatMap { value -> Either<String, String> in
            value > 0 ? .right("positive") : .left("non-positive")
        }
        guard case .right(let value) = chained else {
            Issue.record("expected .right")
            return
        }
        #expect(value == "positive")
    }

    @Test
    func `static flatMap mirrors instance flatMap`() {
        let either: Either<String, Int> = .right(3)
        let viaInstance = either.flatMap(right: { Either<String, Int>.right($0 + 1) })
        let viaStatic = Either<String, Int>.flatMap(
            either,
            right: { Either<String, Int>.right($0 + 1) }
        )
        #expect(viaInstance == viaStatic)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either folding evaluates the active arm` {

    @Test
    func `fold collapses left case`() {
        let either: Either<String, Int> = .left("err")
        let result = either.fold(
            left: { $0.count },
            right: { $0 }
        )
        #expect(result == 3)
    }

    @Test
    func `fold collapses right case`() {
        let either: Either<String, Int> = .right(42)
        let result = either.fold(
            left: { $0.count },
            right: { $0 }
        )
        #expect(result == 42)
    }

    @Test
    func `fold propagates typed throws from left handler`() {
        struct Failure: Swift.Error, Equatable {}
        let either: Either<String, Int> = .left("err")
        do throws(Failure) {
            _ = try either.fold(
                left: { (_: String) throws(Failure) -> Int in throw Failure() },
                right: { (value: Int) throws(Failure) -> Int in value }
            )
            Issue.record("expected throw")
        } catch {
            #expect(error == Failure())
        }
    }

    @Test
    func `static fold mirrors instance fold`() {
        let either: Either<String, Int> = .right(7)
        let viaInstance = either.fold(left: { $0.count }, right: { $0 })
        let viaStatic = Either<String, Int>.fold(either, left: { $0.count }, right: { $0 })

        #expect(viaInstance == viaStatic)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Swapping Either exchanges arms and preserves payloads` {

    @Test
    func `swapped exchanges left and right`() {
        let original: Either<String, Int> = .right(42)
        let swapped = original.swapped()
        guard case .left(let value) = swapped else {
            Issue.record("expected .left after swap")
            return
        }
        #expect(value == 42)
    }

    @Test
    func `swapped exchanges left to right`() {
        let original: Either<String, Int> = .left("done")
        let swapped = original.swapped()
        guard case .right(let value) = swapped else {
            Issue.record("expected .right after swap")
            return
        }
        #expect(value == "done")
    }

    @Test
    func `swapped twice is identity`() {
        let original: Either<String, Int> = .right(7)
        #expect(original.swapped().swapped() == original)
    }

    @Test
    func `static swapped mirrors instance swapped`() {
        let original: Either<String, Int> = .right(11)
        #expect(Either<String, Int>.swapped(original) == original.swapped())
    }

    @Test
    func `swapped admits noncopyable nonescapable right arm`() {
        struct View: ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let original: Either<Int, View> = .right(View(7))
        let flipped = original.swapped()
        guard case .left(let value) = flipped else {
            Issue.record("expected .left after swap")
            return
        }
        #expect(value.id == 7)
    }

    @Test
    func `swapped admits noncopyable nonescapable left arm`() {
        struct View: ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let original: Either<View, Int> = .left(View(5))
        let flipped = original.swapped()
        guard case .right(let value) = flipped else {
            Issue.record("expected .right after swap")
            return
        }
        #expect(value.id == 5)
    }

    @Test
    func `swapped admits ~Copyable & ~Escapable right arm`() {
        struct Span: ~Copyable, ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let original: Either<Int, Span> = .right(Span(13))
        let flipped = original.swapped()
        guard case .left(let value) = flipped else {
            Issue.record("expected .left after swap")
            return
        }
        #expect(value.id == 13)
    }

    @Test
    func `swapped admits ~Copyable & ~Escapable left arm`() {
        struct Span: ~Copyable, ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let original: Either<Span, Int> = .left(Span(17))
        let flipped = original.swapped()
        guard case .right(let value) = flipped else {
            Issue.record("expected .right after swap")
            return
        }
        #expect(value.id == 17)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either accessors return only the active payload` {

    @Test
    func `left accessor returns Some on .left`() {
        let either: Either<String, Int> = .left("x")
        #expect(either.left == "x")
        #expect(either.right == nil)
    }

    @Test
    func `right accessor returns Some on .right`() {
        let either: Either<String, Int> = .right(9)
        #expect(either.right == 9)
        #expect(either.left == nil)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either eliminates impossible arms without losing the remaining payload` {

    @Test
    func `Either where Right == Never extracts left as value`() {
        let only: Either<String, Never> = .left("done")
        #expect(only.value == "done")
    }

    @Test
    func `Either where Left == Never extracts right as value`() {
        let only: Either<Never, Int> = .right(7)
        #expect(only.value == 7)
    }

    @Test
    func `value of free function on copyable right matches property`() {
        let only: Either<Never, Int> = .right(11)
        let viaProp = only.value
        let viaFree = value(of: only)
        #expect(viaProp == viaFree)
        #expect(viaFree == 11)
    }

    @Test
    func `value of free function extracts noncopyable right`() {
        struct Resource: ~Copyable {
            let id: Int
        }
        let only: Either<Never, Resource> = .right(Resource(id: 42))
        let extracted = value(of: only)
        #expect(extracted.id == 42)
    }

    @Test
    func `value of free function extracts noncopyable left`() {
        struct Resource: ~Copyable {
            let id: Int
        }
        let only: Either<Resource, Never> = .left(Resource(id: 99))
        let extracted = value(of: only)
        #expect(extracted.id == 99)
    }

    @Test
    func `value of free function admits noncopyable nonescapable right`() {
        struct View: ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let only: Either<Never, View> = .right(View(42))
        let extracted = value(of: only)
        #expect(extracted.id == 42)
    }

    @Test
    func `value of free function admits noncopyable nonescapable left`() {
        struct View: ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let only: Either<View, Never> = .left(View(99))
        let extracted = value(of: only)
        #expect(extracted.id == 99)
    }

    @Test
    func `value of free function admits ~Copyable & ~Escapable right`() {
        struct Span: ~Copyable, ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let only: Either<Never, Span> = .right(Span(23))
        let extracted = value(of: only)
        #expect(extracted.id == 23)
    }

    @Test
    func `value of free function admits ~Copyable & ~Escapable left`() {
        struct Span: ~Copyable, ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let only: Either<Span, Never> = .left(Span(29))
        let extracted = value(of: only)
        #expect(extracted.id == 29)
    }

    @Test
    func `Either Never Never type declarable and function-accepting compiles`() {

        func _accepts(_: Either<Never, Never>) -> Never {
            fatalError("uninhabited")
        }

        let _: (Either<Never, Never>) -> Never = _accepts
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either equality hashing and descriptions preserve arm identity` {

    @Test
    func `Either is Equatable when both arms are Equatable`() {
        let a: Either<String, Int> = .right(1)
        let b: Either<String, Int> = .right(1)
        let c: Either<String, Int> = .right(2)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Either is Hashable when both arms are Hashable`() {
        let set: Set<Either<String, Int>> = [.left("a"), .right(1), .left("a")]
        #expect(set.count == 2)
    }

    struct Refusal: Swift.Error, Equatable {}
    struct Conflict: Swift.Error, Equatable {}

    @Test
    func `Either is throwable when both arms are throwable`() {
        let e: Either<Refusal, Conflict> = .left(Refusal())
        let asAnyError: any Swift.Error = e
        _ = asAnyError
    }

    @Test
    func `Either is Codable when both arms are Codable`() {

        func _requireCodable<T: Codable>(_: T.Type) {}
        _requireCodable(Either<String, Int>.self)
        _requireCodable(Either<Int, Bool>.self)
    }

    @Test
    func `Either is BitwiseCopyable when both arms are BitwiseCopyable`() {
        func _requireBitwiseCopyable<T: BitwiseCopyable>(_: T.Type) {}
        _requireBitwiseCopyable(Either<Int, Bool>.self)
        _requireBitwiseCopyable(Either<UInt8, UInt32>.self)
    }

    @Test
    func `Either is Sendable when both arms are Sendable (Copyable case)`() {
        struct Token: Sendable { let id: Int }
        func _requireSendable<T: Sendable>(_: T.Type) {}
        _requireSendable(Either<Token, Token>.self)
        _requireSendable(Either<String, Int>.self)
    }

    @Test
    func `Either is Sendable when both arms are ~Copyable & Sendable`() {

        struct Resource: ~Copyable, Sendable { let id: Int }
        func _requireSendable<T: Sendable & ~Copyable & ~Escapable>(_: T.Type) {}
        _requireSendable(Either<Resource, Resource>.self)
    }

    @Test
    func `Either is Copyable when both arms are Copyable`() {
        func _requireCopyable<T: Copyable>(_: T.Type) {}
        _requireCopyable(Either<String, Int>.self)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics` {

    struct Probe: ~Copyable {
        let id: Int
    }

    @Test
    func `Either<Probe, Probe> conforms to Equatable`() {
        func _requireEquatable<T: Swift.Equatable & ~Copyable>(_: T.Type) {}
        _requireEquatable(Either<Probe, Probe>.self)
    }

    @Test
    func `Either<Probe, Probe> conforms to Hashable`() {
        func _requireHashable<T: Swift.Hashable & ~Copyable>(_: T.Type) {}
        _requireHashable(Either<Probe, Probe>.self)
    }

    @Test
    func `Either<Probe, Probe> conforms to Comparable`() {
        func _requireComparable<T: Swift.Comparable & ~Copyable>(_: T.Type) {}
        _requireComparable(Either<Probe, Probe>.self)
    }

    @Test
    func `Equatable equality on ~Copyable arms compares left payloads`() {
        let a: Either<Probe, Probe> = .left(Probe(id: 7))
        let b: Either<Probe, Probe> = .left(Probe(id: 7))
        let c: Either<Probe, Probe> = .left(Probe(id: 9))

        let abEqual = a == b
        let acEqual = a == c
        #expect(abEqual)
        #expect(!acEqual)
    }

    @Test
    func `Equatable equality on ~Copyable arms compares right payloads`() {
        let a: Either<Probe, Probe> = .right(Probe(id: 3))
        let b: Either<Probe, Probe> = .right(Probe(id: 3))
        let c: Either<Probe, Probe> = .right(Probe(id: 4))
        let abEqual = a == b
        let acEqual = a == c
        #expect(abEqual)
        #expect(!acEqual)
    }

    @Test
    func `Equatable distinguishes left from right`() {
        let l: Either<Probe, Probe> = .left(Probe(id: 1))
        let r: Either<Probe, Probe> = .right(Probe(id: 1))
        let lrEqual = l == r
        #expect(!lrEqual)
    }

    @Test
    func `Comparable orders left before right regardless of payload`() {
        let l: Either<Probe, Probe> = .left(Probe(id: 999))
        let r: Either<Probe, Probe> = .right(Probe(id: 0))
        let leftLessThanRight = l < r
        let rightLessThanLeft = r < l
        #expect(leftLessThanRight)
        #expect(!rightLessThanLeft)
    }

    @Test
    func `Comparable orders payloads within matching cases`() {
        let l1: Either<Probe, Probe> = .left(Probe(id: 1))
        let l2: Either<Probe, Probe> = .left(Probe(id: 2))
        let r1: Either<Probe, Probe> = .right(Probe(id: 1))
        let r2: Either<Probe, Probe> = .right(Probe(id: 2))
        let same: Either<Probe, Probe> = .left(Probe(id: 5))

        let leftLeftOrdered = l1 < l2
        let rightRightOrdered = r1 < r2
        let irreflexive = same < same

        #expect(leftLeftOrdered)
        #expect(rightRightOrdered)
        #expect(!irreflexive)
    }

    @Test
    func `Hashable hashes left and right cases distinctly`() {
        let l: Either<Probe, Probe> = .left(Probe(id: 42))
        let r: Either<Probe, Probe> = .right(Probe(id: 42))

        var leftHasher = Hasher()
        l.hash(into: &leftHasher)
        var rightHasher = Hasher()
        r.hash(into: &rightHasher)

        #expect(leftHasher.finalize() != rightHasher.finalize())
    }

    @Test
    func `Hashable equal values produce equal hashes (left)`() {
        let a: Either<Probe, Probe> = .left(Probe(id: 11))
        let b: Either<Probe, Probe> = .left(Probe(id: 11))
        var ha = Hasher()
        a.hash(into: &ha)
        var hb = Hasher()
        b.hash(into: &hb)
        #expect(ha.finalize() == hb.finalize())
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics`.Probe: Swift.Equatable {
    static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics`.Probe: Swift.Comparable {
    static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.id < rhs.id
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics`.Probe: Swift.Hashable {
    borrowing func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics` {

    struct Cell: ~Copyable {
        let id: Int
    }

    @Test
    func `Either<Cell, Cell> conforms to Equatable`() {
        func _requireEquatable<T: Swift.Equatable & ~Copyable>(_: T.Type) {}
        _requireEquatable(Either<Cell, Cell>.self)
    }

    @Test
    func `Either<Cell, Cell> conforms to Hashable`() {
        func _requireHashable<T: Swift.Hashable & ~Copyable>(_: T.Type) {}
        _requireHashable(Either<Cell, Cell>.self)
    }

    @Test
    func `Either<Cell, Cell> conforms to Comparable`() {
        func _requireComparable<T: Swift.Comparable & ~Copyable>(_: T.Type) {}
        _requireComparable(Either<Cell, Cell>.self)
    }

    @Test
    func `Either intrinsic equality compares noncopyable payloads`() {
        let a: Either<Cell, Cell> = .left(Cell(id: 7))
        let b: Either<Cell, Cell> = .left(Cell(id: 7))
        let c: Either<Cell, Cell> = .left(Cell(id: 9))
        let abEqual = a == b
        let acEqual = a == c
        #expect(abEqual)
        #expect(!acEqual)
    }

    @Test
    func `Comparable orders left before right on ~Copyable arms`() {
        let l: Either<Cell, Cell> = .left(Cell(id: 999))
        let r: Either<Cell, Cell> = .right(Cell(id: 0))
        let leftLessThanRight = l < r
        #expect(leftLessThanRight)
    }

    @Test
    func `Hashable equal values produce equal hashes on ~Copyable arms`() {
        let a: Either<Cell, Cell> = .left(Cell(id: 11))
        let b: Either<Cell, Cell> = .left(Cell(id: 11))
        var ha = Hasher()
        a.hash(into: &ha)
        var hb = Hasher()
        b.hash(into: &hb)
        #expect(ha.finalize() == hb.finalize())
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics`.Cell: Swift.Equatable {
    static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics`.Cell: Swift.Hashable {
    borrowing func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Either intrinsic conformances preserve payload and arm semantics`.Cell: Swift.Comparable {
    static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.id < rhs.id
    }
}

extension `Either operations preserve the active arm and its payload`.`Either construction transformation and conformances preserve arm semantics`.`Consuming Either operations support noncopyable payloads` {

    struct Resource: ~Copyable {
        let id: Int
        init(_ id: Int) { self.id = id }
    }

    struct Tag: ~Copyable {
        let label: String
        init(_ label: String) { self.label = label }
    }

    @Test
    func `Consuming Either maps the right payload with noncopyable arms`() {
        let either: Either<Resource, Resource> = .right(Resource(7))
        let mapped = either.map(right: { (r: consuming Resource) -> Tag in
            Tag("from-id-\(r.id)")
        })
        guard case .right(let other) = mapped else {
            Issue.record("expected .right after consuming map(right:)")
            return
        }
        #expect(other.label == "from-id-7")
    }

    @Test
    func `Consuming Either maps the left payload with noncopyable arms`() {
        let either: Either<Resource, Resource> = .left(Resource(11))
        let mapped = either.map(left: { (r: consuming Resource) -> Tag in
            Tag("left-id-\(r.id)")
        })
        guard case .left(let other) = mapped else {
            Issue.record("expected .left after consuming map(left:)")
            return
        }
        #expect(other.label == "left-id-11")
    }

    @Test
    func `Consuming Either maps the active payload with noncopyable arms`() {
        let either: Either<Resource, Resource> = .right(Resource(42))
        let mapped = either.map(
            left: { (l: consuming Resource) -> Tag in Tag("L\(l.id)") },
            right: { (r: consuming Resource) -> Tag in Tag("R\(r.id)") }
        )
        guard case .right(let other) = mapped else {
            Issue.record("expected .right after consuming bimap")
            return
        }
        #expect(other.label == "R42")
    }

    @Test
    func `Consuming Either swaps arms with noncopyable arms`() {
        let either: Either<Resource, Tag> = .right(Tag("orig"))
        let swapped = either.swapped()
        guard case .left(let other) = swapped else {
            Issue.record("expected .left after consuming swap")
            return
        }
        #expect(other.label == "orig")
    }

    @Test
    func `Consuming Either folds the active payload with noncopyable arms`() {
        let either: Either<Resource, Tag> = .right(Tag("folded"))
        let result = either.fold(
            left: { (r: consuming Resource) -> Int in r.id },
            right: { (o: consuming Tag) -> Int in o.label.count }
        )
        #expect(result == 6)
    }

    @Test
    func `Consuming Either flat maps the right payload with noncopyable arms`() {
        let either: Either<Resource, Resource> = .right(Resource(5))
        let chained = either.flatMap(right: {
            (r: consuming Resource) -> Either<Resource, Tag> in
            r.id > 0 ? .right(Tag("positive-\(r.id)")) : .left(Resource(-1))
        })
        guard case .right(let other) = chained else {
            Issue.record("expected .right after consuming flatMap(right:)")
            return
        }
        #expect(other.label == "positive-5")
    }

    @Test
    func `Consuming Either flat maps the left payload with noncopyable arms`() {
        let either: Either<Resource, Resource> = .left(Resource(404))
        let chained = either.flatMap(left: {
            (l: consuming Resource) -> Either<Tag, Resource> in
            .left(Tag("err-\(l.id)"))
        })
        guard case .left(let other) = chained else {
            Issue.record("expected .left after consuming flatMap(left:)")
            return
        }
        #expect(other.label == "err-404")
    }
}
