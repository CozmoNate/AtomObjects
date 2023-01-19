//
//  Created by Natan Zalkin on 12/01/2023.
//  Copyright © 2023 Natan Zalkin. All rights reserved.
//
    

import SwiftUI
import AtomObjects

struct ContentView: View {
    
    @AtomState(\CommonAtoms.counter)
    var counter
    
    var body: some View {
        VStack {
            Text("Counter: \(counter)")
            Controls()
            
            SecondaryView()
                .atomScope(root: CommonAtoms())
            
            TertiaryView()
                .atomScope(root: CommonAtoms())
            
            QuaternaryView()
                .atomScope(root: CommonAtoms())
        }
        .padding()
    }
}

struct Controls: View {
    
    @AtomState(\CommonAtoms.counter)
    var counter
    
    @AtomAction(CommonAtoms.IncrementCounter(by: 1))
    var increment
    
    @AtomAction(CommonAtoms.IncrementCounter(by: -1))
    var decrement
    
    @State
    var isEditing = false
    
    var body: some View {
        HStack {
            Button {
                decrement()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
            }
            
            Slider(value: Binding {
                Float(counter)
            } set: { newValue in
                counter = Int(newValue)
            }, in: 0...10) {
                isEditing = $0
            }
            
            Button {
                increment()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
        }
    }
}

struct SecondaryView: View {
    
    @AtomState(\CommonAtoms.counter)
    var counter
    
    var body: some View {
        VStack {
            Text("Secondary counter: \(counter)")
            Controls()
        }
    }
}

struct TertiaryView: View {
    
    @AtomState(\CommonAtoms.counter, set: { newValue, atom in
        atom.value = newValue < atom.value ? newValue - 1 : newValue + 1
    })
    var counter
    
    @EnvironmentObject
    var root: CommonAtoms
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    counter -= 1
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                }
                
                Spacer()
                
                Text("Tertiary counter: \(counter)")
                
                Spacer()
                
                Button {
                    counter += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
            }
            
            Button {
                root.counter = GenericAtom(value: 5)
            } label: {
                Text("Rewrite atom")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("rewrite")
        }
        .padding(.vertical)
    }
}

struct QuaternaryView: View {
    
    @AtomState(\CommonAtoms.counter)
    var counter
    
    @AtomDispatcher(CommonAtoms.self)
    var dispatcher
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dispatcher.dispatch(CommonAtoms.DecrementCounter(by: counter == 0 ? 1 : abs(counter)))
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                }
                
                Spacer()
                
                Text("Quaternary counter: \(counter)")
                
                Spacer()
                
                Button {
                    dispatcher.dispatch(CommonAtoms.IncrementCounter(by: counter == 0 ? 1 : abs(counter)))
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
            }
        }
        .padding(.vertical)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AtomScope(root: CommonAtoms()) {
            ContentView()
        }
    }
}
