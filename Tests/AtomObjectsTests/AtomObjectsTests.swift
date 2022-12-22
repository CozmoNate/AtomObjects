import Quick
import Nimble
import Combine
import Foundation

@testable import AtomObjects

final class CounterAtom: AtomObject {
    
    static var `default` = CounterAtom()
    
    @Published var value: Int = 0
}

extension AtomObjects {
    
    var counter: CounterAtom {
        get { return self[CounterAtom.self] }
        set { self[CounterAtom.self] = newValue }
    }
}

final class DependenciesTests: QuickSpec {
    override func spec() {
        
        describe("AtomObjects") {
            
            context("@AtomValue by passing keyPath") {
                
                @AtomValue(\.counter)
                var counter: Int
                
                it("should be available with default value") {
                    expect(counter).to(equal(0))
                }
                
                it("should be mutable") {
                    counter = 42
                    expect(counter).to(equal(42))
                }
            }
            
            context("Access projectedValue if @AtomObject") {
                
                @AtomState(\.counter)
                var counter: Int
                
                it("should allow to change shared state and notify subscribers") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        expect(counter).to(equal(42))
                        
                        subscription = CounterAtom.default.objectWillChange.receive(on: DispatchQueue.main).sink { _ in
                            expect(counter).to(equal(11))
                            done()
                        }
                        
                        expect(subscription).notTo(beNil())
                        
                        counter = 11
                    }
                }
                
                it("should provide value working binding") {
                    
                    var subscription: AnyCancellable?
                    
                    waitUntil { done in
                        
                        expect($counter.wrappedValue).to(equal(11))
                        
                        subscription = CounterAtom.default.objectWillChange.receive(on: DispatchQueue.main).sink { _ in
                            expect($counter.wrappedValue).to(equal(42))
                            done()
                        }
                        
                        expect(subscription).notTo(beNil())
                        
                        $counter.wrappedValue = 42
                    }
                }
            }
        }
        
    }
}