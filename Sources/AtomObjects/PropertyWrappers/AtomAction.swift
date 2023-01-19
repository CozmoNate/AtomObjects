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

/// A property wrapper type that stores an action of a specified type with possibility of executing it later with the actual root.
@propertyWrapper
public struct AtomAction<Action>: DynamicProperty where Action: AtomRootAction {
    
    public typealias Root = Action.Root
    public typealias SyncInvocation = () -> Void
    public typealias AsyncInvocation = () async -> Void
    
    private class Wrapper<Action>: ObservableObject where Action: AtomRootAction {
        
        let action: Action
        
        init(action: Action) {
            self.action = action
        }
    }
    
    @EnvironmentObject
    private var root: Root
    
    @StateObject
    private var wrapper: Wrapper<Action>
    
    public var wrappedValue: SyncInvocation {
        return { [weak wrapper] in
            Task {
                await wrapper?.action.perform(with: root)
            }
        }
    }
    
    public var projectedValue: AsyncInvocation {
        return { [weak wrapper] in
            await wrapper?.action.perform(with: root)
        }
    }
    
    public init(_ action: @autoclosure @escaping () -> Action) {
        _wrapper = StateObject(wrappedValue: Wrapper(action: action()))
    }
}
