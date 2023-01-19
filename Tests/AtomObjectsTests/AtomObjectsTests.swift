import Quick
import Nimble
import Combine
import Foundation

@testable import AtomObjects

final class AtomObjectsTests: QuickSpec {
    override func spec() {
        
        describe("AtomObjects") {
            
            context("santiy test") {
                
                it("should compile") {
                    expect(42).to(equal(42))
                }
            }
        }
    }
}
