import Quick
import Nimble
import Combine
import Foundation

@testable import AtomObjects

class CounterAtom: AtomObject {
    @Published var value: Int = 0
}

struct CounterAtomKey: AtomObjectKey {
    static var defaultAtom = CounterAtom()
}

class ComplexAtom: AtomObject {
    
    struct Value {
        var count: Int = 0
    }
    
    @Published var value = Value()
}

struct ComplexAtomKey: AtomObjectKey {
    static var defaultAtom = ComplexAtom()
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
}

final class DependenciesTests: QuickSpec {
    override func spec() {
        
        describe("AtomObjects") {
            
            context("@AtomValue") {
                
                @AtomValue(\.counter, set: { newValue, oldValue in newValue == 11 ? 11 : newValue })
                var counter: Int
                
                it("should be available with default value") {
                    expect(counter).to(equal(0))
                }
                
                it("should be mutable") {
                    counter = 42
                    expect(counter).to(equal(42))
                }
            }
            
            context("@AtomValue: custom setter") {
                
                @AtomValue(\.counter, set: { newValue, oldValue in newValue == 11 ? 111 : newValue })
                var counter: Int
                
                it("should be available with default value") {
                    expect(counter).to(equal(42))
                }
                
                it("should use custom setter") {
                    counter = 11
                    expect(counter).to(equal(111))
                }
            }
            
            context("@AtomState: access projectedValue") {
                
                @AtomState(\.counter)
                var counter: Int
                
                it("should allow to change shared state and notify subscribers") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        expect(counter).to(equal(111))
                        
                        subscription = CounterAtomKey.defaultAtom
                            .objectWillChange.receive(on: DispatchQueue.main).sink { _ in
                                expect(counter).to(equal(11))
                                done()
                            }
                        
                        expect(subscription).notTo(beNil())
                        
                        counter = 11
                    }
                }
                
                it("should provide value binding") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        expect($counter.wrappedValue).to(equal(11))
                        
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
                
                @AtomState(\.counter, set: { newValue, oldValue in newValue == 11 ? 111 : newValue })
                var counter: Int
                
                it("should be available with default value") {
                    expect(counter).to(equal(42))
                }
                
                it("should use custom setter") {
                    counter = 11
                    expect(counter).to(equal(111))
                }
            }
            
            context("@AtomState: access complex value") {
                
                @AtomState(\.complex)
                var complex: ComplexAtom.Value
                
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
        }
        
    }
}
