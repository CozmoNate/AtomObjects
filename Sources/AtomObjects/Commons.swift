//
//  Created by Natan Zalkin on 31/12/2022.
//  Copyright © 2022 Natan Zalkin. All rights reserved.
//
    

import Combine

internal extension Equatable {
    
    func isEqual<Other>(_ other: Other) -> Bool {
        if let other = other as? Self {
            return self == other
        }
        return false
    }
}

internal extension AtomObject {
    
    func setThenNotEqual(_ newValue: Value) {
        if let value = value as? any Equatable {
            guard !value.isEqual(newValue) else {
                return
            }
        }
        value = newValue
    }
}
