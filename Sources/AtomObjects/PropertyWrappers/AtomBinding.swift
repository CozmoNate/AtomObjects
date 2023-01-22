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
import Combine

/// A property wrapper type that can read and write a value of a specific atom. It does NOT refreshes views when the value is changed.
@propertyWrapper
public struct AtomBinding<Root, Atom, Value>: DynamicProperty, Equatable where Root: AtomRoot, Atom: AtomObject, Atom.Value == Value {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.keyPath == rhs.keyPath
    }
    
    @EnvironmentObject
    private var root: Root
    
    private var keyPath: ReferenceWritableKeyPath<Root, Atom>
    private var setter: ((_ newValue: Value, _ atomObject: Atom) -> Void)?
    
    private var atom: Atom {
        root[keyPath: keyPath]
    }
    
    @MainActor
    public var wrappedValue: Value {
        get { atom.value } nonmutating set {
            setter?(newValue, atom) ?? atom.setThenNotEqual(newValue)
        }
    }
    
    @MainActor
    public var projectedValue: Binding<Value> {
        Binding { atom.value } set: { newValue in
            setter?(newValue, atom) ?? atom.setThenNotEqual(newValue)
        }
    }
    
    /// Creates a proxy for a specific atom value. It does NOT refreshes a view when the atom value is changed.
    ///
    /// - Parameters:
    ///   - keyPath: A key path to a specific atom in the root.
    ///   - root: An atom root type.
    ///   - set: An in-place atom value setter.
    public init(
        _ keyPath: ReferenceWritableKeyPath<Root, Atom>,
        root: Root.Type = Root.self,
        set: ((_ newValue: Value, _ atomObject: Atom) -> Void)? = nil
    ) {
        self.keyPath = keyPath
        self.setter = set
    }
}
