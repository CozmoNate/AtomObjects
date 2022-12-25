/*
 
AtomObjects
 
Copyright (c) 2022 Natan Zalkin

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
import SwiftUI

public protocol AtomObject: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    
    associatedtype Value
    
    var value: Value { get set }
}

public protocol AtomObjectKey {
    
    associatedtype Atom: AtomObject
    
    static var defaultAtom: Atom { get }
}

public protocol AtomObjectsContainer: AnyObject {
    
    subscript<Key>(key: Key.Type) -> Key.Atom where Key: AtomObjectKey { get set }
}

open class AtomObjects: AtomObjectsContainer {

    public static let `default` = AtomObjects()

    private var storage = [ObjectIdentifier: any AtomObject]()
    
    public subscript<Key>(key: Key.Type) -> Key.Atom where Key: AtomObjectKey {
        get { storage[ObjectIdentifier(Key.self)] as? Key.Atom ?? Key.defaultAtom }
        set { storage[ObjectIdentifier(Key.self)] = newValue }
    }
    
    public init() {}
}

/// A property wrapper type that can read and write a value of a specified atom and refresh the view when the value is changed
@propertyWrapper
public struct AtomValue<Atom, Container>: DynamicProperty where Atom: AtomObject, Container: AtomObjectsContainer {
    
    public typealias Value = Atom.Value
    
    public var wrappedValue: Value {
        get {
            return atom.value
        }
        nonmutating set {
            atom.value = setter?(newValue, atom.value) ?? newValue
        }
    }
    
    private var atom: Atom
    private let setter: ((Value, Value) -> Value)?
    
    public init(
        _ keyPath: ReferenceWritableKeyPath<Container, Atom>,
        container: Container = AtomObjects.default,
        set: ((_ newValue: Value, _ oldValue: Value) -> Value)? = nil
    ) {
        atom = container[keyPath: keyPath]
        setter = set
    }
}

/// A property wrapper type that can read and write a value of a specified atom. It does not refresh the view when the value is changed.
@propertyWrapper
public struct AtomState<Atom, Container>: DynamicProperty where Atom: AtomObject, Container: AtomObjectsContainer {
    
    public typealias Value = Atom.Value
    
    public var wrappedValue: Value {
        get {
            return atom.value
        }
        nonmutating set {
            atom.value = setter?(newValue, atom.value) ?? newValue
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding {
            return atom.value
        } set: { newValue in
            atom.value = setter?(newValue, atom.value) ?? newValue
        }
    }
    
    @ObservedObject
    private var atom: Atom
    private let setter: ((Value, Value) -> Value)?
    
    public init(
        _ keyPath: ReferenceWritableKeyPath<Container, Atom>,
        container: Container = AtomObjects.default,
        set: ((_ newValue: Value, _ oldValue: Value) -> Value)? = nil
    ) {
        atom = container[keyPath: keyPath]
        setter = set
    }
}
