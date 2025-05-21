//
//  Mouse_Don_t_Sleep_App.swift
//  Mouse Don't Sleep!
//
//  Created by Tk on 2025/5/21.
//

import SwiftUI
import SwiftData

@main
struct Mouse_Don_t_Sleep_App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Tabs()
        }
        .modelContainer(sharedModelContainer)
    }
}
