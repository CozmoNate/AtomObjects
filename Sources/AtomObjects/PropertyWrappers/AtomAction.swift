/*
 
AtomObjects
 
Copyright (c) 2023 Natan Zalkin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
*/
    

import SwiftUI

/// A property wrapper type that exposes the invocation of an action of the specified type with the actual root.
@propertyWrapper
public struct AtomAction<Action>: DynamicProperty, Equatable where Action: AtomRootAction {
    
    public typealias Root = Action.Root
    public typealias SyncInvocation = () -> Void
    public typealias AsyncInvocation = () async -> Void
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        true
    }
    
    @EnvironmentObject
    private var root: Root
    
    private var action: () -> Action
    
    public var wrappedValue: SyncInvocation {
        return {
            Task {
                await action().perform(with: root)
            }
        }
    }
    
    public var projectedValue: AsyncInvocation {
        return {
            await action().perform(with: root)
        }
    }
    
    public init(_ action: @autoclosure @escaping () -> Action) {
        self.action = action
    }
}
