# AtomObjects for SwiftUI

[![License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/kzlekk/AtomObjects/raw/master/LICENSE)
![Language](https://img.shields.io/badge/swift-5.7-orange.svg)
![Coverage](https://img.shields.io/badge/coverage-97%25-green)

AtomObjects is a lightweight state management library for SwiftUI. It allows building distributed & reusable shared 
states for SwiftUI applications with minimum boilerplate code.

## Motivation

The main idea is to use small "decentralized" atom state primitives instead of a centralized store or data model. 
Atom objects easily allow pinpoint refreshes of SwiftUI views instead of trying to think out an efficient 
update strategy for bigger data models. Although it is not encouraged, you can always build more complex atoms 
with AtomObjects if necessary.

## Installation

### Swift Package Manager

Add "AtomObjects" dependency via integrated Swift Package Manager in XCode

## Usage

The first step is implementing an atom class conforming to the AtomObject protocol:

```swift
class EditingAtom: AtomObject {
    
    // Published property wrapper is needed allowing to trigger value updates.
    // Also, you can start update manually by calling objectWillChange.send() where appropriate.
    @Published var value: Bool
}

struct EditingAtomKey: AtomObjectKey {

    static var defaultAtom = EditingAtom(value: false)
}

```

Then you need to register your atom in the container:

```swift
// Register in the default container
extension AtomObjects {
    
    var isEditing: EditingAtom {
        get { return self[EditingAtomKey.self] }
        set { self[EditingAtomKey.self] = newValue }
    }
}
```

After that, you can use @AtomState wrapper in SwiftUI view, which will refresh view automatically when the atom is changed:

```swift
struct HomeView: View {
    
    @AtomState(\.isEditing)
    var isEditing

    var body: some View {
        Button {
            isEditing.toggle()
        } label: {
            Text("Edit")
        }
        .popover(isPresented: $isEditing) {
            EditorView()
        }
    }
}
```

If you only need to update the atom value without triggering refresh on view, you can use @AtomValue wrapper:

```swift
struct HomeView: View {
    
    @AtomValue(\.isEditing)
    var isEditing

    var body: some View {
        Button {
            isEditing.toggle()
        } label: {
            Text("Edit")
        }
    }
}
```
