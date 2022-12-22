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
    
    static var `default`: Self { get }
    
    var value: Value { get set }
}

public class AtomObjects {
    
    public static let `default` = AtomObjects()
    
    private var storage = [ObjectIdentifier: Any]()
    
    public init() {}
    
    public subscript<Atom>(provider: Atom.Type) -> Atom where Atom: AtomObject {
        get { storage[ObjectIdentifier(Atom.self)] as? Atom ?? Atom.`default` }
        set { storage[ObjectIdentifier(Atom.self)] = newValue }
    }
}

/// A property wrapper type that can read and write a value of a specified atom and refresh the view when the value is changed
@propertyWrapper public struct AtomValue<Atom>: DynamicProperty where Atom: AtomObject {
    
    public typealias Value = Atom.Value
    
    @MainActor public var wrappedValue: Value {
        get {
            return atom.value
        }
        nonmutating set {
            atom.value = newValue
        }
    }
    
    private var atom: Atom
    
    public init(_ keyPath: KeyPath<AtomObjects, Atom>, provider: AtomObjects = .default) {
        atom = provider[keyPath: keyPath]
    }
}

/// A property wrapper type that can read and write a value of a specified atom. It does not refresh the view when the value is changed.
@propertyWrapper public struct AtomState<Atom>: DynamicProperty where Atom: AtomObject {
    
    public typealias Value = Atom.Value
    
    @MainActor public var wrappedValue: Value {
        get {
            return atom.value
        }
        nonmutating set {
            atom.value = newValue
        }
    }
    
    @MainActor public var projectedValue: Binding<Value> {
        Binding {
            return atom.value
        } set: { newValue in
            atom.value = newValue
        }
    }
    
    @ObservedObject private var atom: Atom
    
    public init(_ keyPath: KeyPath<AtomObjects, Atom>, provider: AtomObjects = .default) {
        atom = provider[keyPath: keyPath]
    }
}
