//
//  Created by Natan Zalkin on 31/12/2022.
//  Copyright © 2022 Natan Zalkin. All rights reserved.
//
    

import SwiftUI

/// A property wrapper type that can read and write a value of the specic atom. It does not refreshes views when the value is changed.
@propertyWrapper
public struct AtomValue<Atom, Container> where Atom: AtomObject, Container: AtomObjectsContainer {
    
    internal class Wrapper {
        
        lazy var atom = resolve()
        
        private let resolve: () -> Atom
        
        init(resolver: @autoclosure @escaping () -> Atom) {
            resolve = resolver
        }
    }
    
    public typealias Value = Atom.Value
    
    public var wrappedValue: Value {
        get {
            return wrapper.atom.value
        }
        nonmutating set {
            if let setter {
                setter(newValue, wrapper.atom)
            } else {
                wrapper.atom.setThenNotEqual(newValue)
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding { wrapper.atom.value } set: { newValue in
            if let setter {
                setter(newValue, wrapper.atom)
            } else {
                wrapper.atom.setThenNotEqual(newValue)
            }
        }
    }
    
    private var wrapper: Wrapper
    private let setter: ((_ newValue: Value, _ atomObject: Atom) -> Void)?
    
    /// Creates a proxy for a specific atom value.
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
        wrapper = Wrapper(resolver: container[keyPath: keyPath])
        setter = set
    }
}

extension AtomValue: Equatable where Value: Equatable {}

public extension AtomValue where Self:Equatable {
    
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

extension AtomValue: Hashable where Value: Hashable {}

public extension AtomValue where Self: Hashable {
    
    func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}
