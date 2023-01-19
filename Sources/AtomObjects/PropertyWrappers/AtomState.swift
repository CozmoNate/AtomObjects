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

/// A property wrapper type that can read and write a value of a specific atom and refreshes views when the value is changed.
@propertyWrapper
public struct AtomState<Value, Root>: DynamicProperty where Root: AtomRoot {
    
    public typealias AtomType = AtomObject<Value>
    
    @EnvironmentObject
    private var root: Root
    
    private var keyPath: ReferenceWritableKeyPath<Root, AtomType>
    private var setter: ((_ newValue: Value, _ atomObject: AtomType) -> Void)?
    
    @StateObject
    private var observer = Observer<Value>()
    
    @MainActor
    public var wrappedValue: Value {
        get { observer.value } nonmutating set {
            setter?(newValue, observer.atom) ?? observer.atom.setThenNotEqual(newValue)
        }
    }
    
    @MainActor
    public var projectedValue: Binding<Value> {
        Binding { observer.value } set: { newValue in
            setter?(newValue, observer.atom) ?? observer.atom.setThenNotEqual(newValue)
        }
    }
    
    /// Creates a proxy for a specific atom value that refreshes a view when the atom value is changed.
    ///
    /// - Parameters:
    ///   - keyPath: A key path to a specific atom in the root.
    ///   - root: An atom root type.
    ///   - set: An in-place atom value setter.
    public init(
        _ keyPath: ReferenceWritableKeyPath<Root, AtomType>,
        root: Root.Type = Root.self,
        set: ((_ newValue: Value, _ atomObject: AtomType) -> Void)? = nil
    ) {
        self.keyPath = keyPath
        self.setter = set
    }
    
    public mutating func update() {
        observer.resolve(keyPath, root: root)
    }
}

private extension AtomState {
    
    class Observer<Value>: ObservableObject {
        
        private var subscription: AnyCancellable?
        private var version = UUID()
        
        var atom: AtomObject<Value>! {
            didSet {
                value = atom.value
                subscription = atom.objectWillChange
                    .receive(on: RunLoop.main)
                    .sink { [weak self] _ in
                        if let self {
                            self.objectWillChange.send()
                            self.value = self.atom.value
                        }
                    }
            }
        }
        
        var value: Value!
        
        var isResolved: Bool {
            atom != nil
        }
        
        func resolve<Root>(_ keyPath: ReferenceWritableKeyPath<Root, AtomObject<Value>>, root: Root) where Root: AtomRoot {
            guard version != root.version else {
                return
            }

            version = root.version
            
            let candidate = root[keyPath: keyPath]
            
            if let actual = atom {
                if actual !== candidate {
                    atom = candidate
                }
            } else {
                atom = candidate
            }
        }
    }
}
