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


import Foundation
import Combine

open class AtomRoot: ObservableObject {
    
    internal struct Storage {
        
        var storage = [ObjectIdentifier: AnyObject]()
        
        subscript<Key>(key: Key.Type) -> Key.AtomType? where Key: AtomObjectKey {
            get { storage[ObjectIdentifier(Key.self)] as? AtomObject<Key.Value> }
            set { storage[ObjectIdentifier(Key.self)] = newValue }
        }
    }
    
    internal var storage: Storage
    internal var version: UUID
    
    public required init() {
        storage = Storage()
        version = UUID()
    }
}

public extension AtomRoot {
    
    subscript<Key>(key: Key.Type) -> Key.AtomType where Key: AtomObjectKey {
        get {
            if let atom = storage[Key.self] {
                return atom
            } else {
                let atom = Key.AtomType(value: Key.defaultValue)
                storage[Key.self] = atom
                return atom
            }
        }
        set {
            objectWillChange.send()
            storage[Key.self] = newValue
            version = UUID()
        }
    }
}

