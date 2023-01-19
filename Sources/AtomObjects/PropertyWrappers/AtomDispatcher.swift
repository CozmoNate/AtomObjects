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

/// A property wrapper type that provides a dispatcher that can execute actions with the actual root.
@propertyWrapper
public struct AtomDispatcher<Root>: DynamicProperty where Root: AtomRoot {
    
    public struct Dispatcher {
        
        private var root: Root!
        
        internal mutating func assign(root newRoot: Root) {
            if root !== newRoot {
                root = newRoot
            }
        }
        
        public func dispatch<Action>(_ action: Action) where Action: AtomRootAction, Action.Root == Root {
            Task {
                await action.perform(with: root)
            }
        }
        
        public func dispatch<Action>(_ action: Action) async where Action: AtomRootAction, Action.Root == Root {
            await action.perform(with: root)
        }
    }
    
    internal class Wrapper: ObservableObject  {
        var dispatcher = Dispatcher()
    }
    
    @EnvironmentObject
    private var root: Root
    
    @StateObject
    private var wrapper = Wrapper()
    
    public var wrappedValue: Dispatcher {
        wrapper.dispatcher
    }
    
    public init(_ root: Root.Type) {}
    
    public mutating func update() {
        wrapper.dispatcher.assign(root: root)
    }
}
