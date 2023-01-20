//
//  Created by Natan Zalkin on 12/01/2023.
//  Copyright © 2023 Natan Zalkin. All rights reserved.
//
    

import SwiftUI
import AtomObjects

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            AtomScope(root: AtomObjects()) {
                ContentView()
            }
        }
    }
}
