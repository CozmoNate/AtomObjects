//
//  Created by Natan Zalkin on 31/12/2022.
//  Copyright © 2022 Natan Zalkin. All rights reserved.
//
    

import SwiftUI

/// A property wrapper type that can read and write a value of a specific atom and refreshes views when the value is changed.
@propertyWrapper
public struct AtomState<Atom, Container>: DynamicProperty where Atom: AtomObject, Container: AtomObjectsContainer {
    
    public typealias Value = Atom.Value
    
    public var wrappedValue: Value {
        get {
            return atom.value
        }
        nonmutating set {
            if let setter {
                setter(newValue, atom)
            } else {
                atom.setThenNotEqual(newValue)
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding { atom.value } set: { newValue in
            if let setter {
                setter(newValue, atom)
            } else {
                atom.setThenNotEqual(newValue)
            }
        }
    }
    
    @ObservedObject
    private var atom: Atom
    
    private let setter: ((_ newValue: Value, _ atomObject: Atom) -> Void)?
    
    /// Creates a proxy for a specific atom value that refreshes a view when the atom value is changed.
    ///
    /// - Parameters:
    ///   - keyPath: A key path to a specific atom in the container.
    ///   - container: A container for atoms.
    ///   - set: A custom value setter.
    public init(
        _ keyPath: ReferenceWritableKeyPath<Container, Atom>,
        container: Container = AtomObjects.default,
        set: ((_ newValue: Value, _ atomObject: Atom) -> Void)? = nil
    ) {
        atom = container[keyPath: keyPath]
        setter = set
    }
}

extension AtomState: Equatable where Value: Equatable {}

public extension AtomState where Self:Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
        
    static func == (lhs: Value, rhs: Self) -> Bool {
        lhs == rhs.wrappedValue
    }
    
    static func == (lhs: Self, rhs: Value) -> Bool {
        lhs.wrappedValue == rhs
    }
}

extension AtomState: Hashable where Value: Hashable {}

public extension AtomState where Self: Hashable {
    
    func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}
