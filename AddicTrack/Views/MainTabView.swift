//
//  MainTabView.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
import SwiftData
// import Inject

struct MainTabView: View {
    // @ObserveInjection var inject
    @Environment(\.modelContext) private var modelContext
    @State private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            AddictionListView(settingsViewModel: settingsViewModel)
                .tabItem {
                    Label("Addictions", systemImage: "heart.circle.fill")
                }
            
            SettingsView(viewModel: settingsViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            settingsViewModel.setModelContext(modelContext)
        }
        // .enableInjection()
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [User.self, Addiction.self, AddictionEntry.self], inMemory: true)
}

