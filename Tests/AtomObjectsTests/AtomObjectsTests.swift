import Quick
import Nimble
import Combine
import Foundation

@testable import AtomObjects

class CounterAtom: AtomObject {
    @Published
    var value: Int = 0
}

struct CounterAtomKey: AtomObjectKey {
    static var defaultAtom = CounterAtom()
}

class ComplexAtom: AtomObject {
    
    struct Value {
        var count: Int = 0
    }
    
    @Published
    var value = Value()
}

struct ComplexAtomKey: AtomObjectKey {
    static var defaultAtom = ComplexAtom()
}

class CircularFirstAtom: AtomObject {
    
    struct Key: AtomObjectKey {
        static var defaultAtom = CircularFirstAtom()
    }
    
    @AtomValue(\.secondCircular)
    var second
    
    @Published
    @MainActor var value: Bool = false {
        didSet {
            if value {
                second = false
            }
        }
    }
}

class CirclularSecondAtom: AtomObject {
    
    struct Key: AtomObjectKey {
        static var defaultAtom = CirclularSecondAtom()
    }
    
    @AtomValue(\.firstCircular)
    var first
    
    @Published
    @MainActor var value: Bool = false {
        didSet {
            if value {
                first = false
            }
        }
    }
}

extension AtomObjects {
    var counter: CounterAtom {
        get { return self[CounterAtomKey.self] }
        set { self[CounterAtomKey.self] = newValue }
    }
    
    var complex: ComplexAtom {
        get { return self[ComplexAtomKey.self] }
        set { self[ComplexAtomKey.self] = newValue }
    }
    
    var firstCircular: CircularFirstAtom {
        get { return self[CircularFirstAtom.Key.self] }
        set { self[CircularFirstAtom.Key.self] = newValue }
    }
    
    var secondCircular: CirclularSecondAtom {
        get { return self[CirclularSecondAtom.Key.self] }
        set { self[CirclularSecondAtom.Key.self] = newValue }
    }
}

final class DependenciesTests: QuickSpec {
    override func spec() {
        
        describe("AtomObjects") {
            
            context("@AtomValue") {
                
                @AtomValue(\.counter, set: { $1.value = $0 == 11 ? 11 : $0 }) 
                var counter: Int
                
                it("should be mutable") {
                    counter = 42
                    expect(counter).to(equal(42))
                }
            }
            
            context("@AtomValue: custom setter") {
                
                @AtomValue(\.counter, set: { $1.value = $0 == 11 ? 111 : $0 })
                var counter: Int
                
                it("should use custom setter") {
                    counter = 11
                    expect(counter).to(equal(111))
                }
                
                it("should provide value binding") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        expect($counter.wrappedValue).to(equal(111))
                        
                        subscription = CounterAtomKey.defaultAtom
                            .objectWillChange.receive(on: DispatchQueue.main).sink { _ in
                                expect($counter.wrappedValue).to(equal(42))
                                done()
                            }
                        
                        expect(subscription).notTo(beNil())
                        
                        $counter.wrappedValue = 42
                    }
                }
            }
            
            context("@AtomValue: dependency cycle") {
                
                @AtomValue(\.firstCircular)
                var first: Bool
                
                @AtomValue(\.secondCircular)
                var second: Bool
                
                beforeEach {
                    first = true
                }
                
                it("should allow circular dependencies") {
                    second = true
                    expect(first).to(beFalse())
                    first = true
                    expect(second).to(beFalse())
                }
            }
            
            context("@AtomValue: Hashable") {
                
                let wrapper = AtomValue(\.counter)
                
                it("should be the same as its wrapped value") {
                    expect(wrapper == wrapper).to(beTrue())
                    expect(wrapper == wrapper.wrappedValue).to(beTrue())
                    expect(wrapper.wrappedValue == wrapper).to(beTrue())
                    expect(wrapper.hashValue).to(equal(wrapper.wrappedValue.hashValue))
                }
            }
            
            context("@AtomState: access projectedValue") {
                
                @AtomState(\.counter)
                var counter: Int
                
                beforeEach {
                    counter = 0
                }
                
                it("should allow to change shared state and notify subscribers") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        expect(counter).to(equal(0))
                        
                        subscription = CounterAtomKey.defaultAtom
                            .objectWillChange.receive(on: DispatchQueue.main).sink { _ in
                                expect(counter).to(equal(42))
                                done()
                            }
                        
                        expect(subscription).notTo(beNil())
                        
                        counter = 42
                    }
                }
                
                it("should provide value binding") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        expect($counter.wrappedValue).to(equal(0))
                        
                        subscription = CounterAtomKey.defaultAtom
                            .objectWillChange.receive(on: DispatchQueue.main).sink { _ in
                                expect($counter.wrappedValue).to(equal(42))
                                done()
                            }
                        
                        expect(subscription).notTo(beNil())
                        
                        $counter.wrappedValue = 42
                    }
                }
            }
            
            context("@AtomState: custom setter") {
                
                @AtomState(\.counter, set: { $1.value = $0 == 11 ? 111 : $0 })
                var counter: Int
                
                it("should use custom setter") {
                    counter = 11
                    expect(counter).to(equal(111))
                }
            }
            
            context("@AtomState: access complex value") {
                
                @AtomState(\.complex)
                var complex: ComplexAtom.Value
                
                beforeEach {
                    complex.count = 0
                }
                
                it("should provide value binding") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        let binding = $complex.count
                        
                        expect(binding.wrappedValue).to(equal(0))
                        
                        subscription = ComplexAtomKey.defaultAtom
                            .objectWillChange.receive(on: DispatchQueue.main).sink { _ in
                                expect(binding.wrappedValue).to(equal(42))
                                done()
                            }
                        
                        expect(subscription).notTo(beNil())
                        
                        binding.wrappedValue = 42
                    }
                }
            }
            
            context("@AtomState: Hashable") {
                
                let wrapper = AtomState(\.counter)
                
                it("should be the same as its wrapped value") {
                    expect(wrapper == wrapper).to(beTrue())
                    expect(wrapper == wrapper.wrappedValue).to(beTrue())
                    expect(wrapper.wrappedValue == wrapper).to(beTrue())
                    expect(wrapper.hashValue).to(equal(wrapper.wrappedValue.hashValue))
                }
            }
        }
    }
}
