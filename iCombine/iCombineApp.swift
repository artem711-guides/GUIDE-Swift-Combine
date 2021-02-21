//
//  iCombineApp.swift
//  iCombine
//
//  Created by Артём Мошнин on 20/2/21.
//

import SwiftUI

@main
struct iCombineApp: App {
    let persistenceContainer = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            TodosView()
                .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
        }
    }
}
