//
//  AddicTrackApp.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
import SwiftData

@main
struct AddicTrackApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Addiction.self,
            AddictionEntry.self,
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
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
