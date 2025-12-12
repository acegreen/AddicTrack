//
//  AddictionDetailViewModel.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class AddictionDetailViewModel {
    var addiction: Addiction
    var entries: [AddictionEntry] = []
    var isLoading = false
    var errorMessage: String?
    
    private var modelContext: ModelContext?
    
    init(addiction: Addiction) {
        self.addiction = addiction
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadEntries()
    }
    
    func loadEntries() {
        isLoading = true
        errorMessage = nil
        
        // Use the relationship to get entries directly
        entries = addiction.entries?.sorted(by: { $0.timestamp > $1.timestamp }) ?? []
        
        isLoading = false
    }
    
    func addEntry(notes: String?, intensity: Int?, timestamp: Date = Date()) {
        guard let modelContext = modelContext else { return }
        
        let newEntry = AddictionEntry(timestamp: timestamp, notes: notes, intensity: intensity, addiction: addiction)
        modelContext.insert(newEntry)
        
        // Add entry to addiction's entries array
        if addiction.entries == nil {
            addiction.entries = []
        }
        addiction.entries?.append(newEntry)
        
        loadEntries()
    }
    
    func deleteEntry(_ entry: AddictionEntry) {
        guard let modelContext = modelContext else { return }
        
        withAnimation {
            modelContext.delete(entry)
            addiction.entries?.removeAll(where: { $0.id == entry.id })
            loadEntries()
        }
    }
    
    // Statistics
    var totalEntries: Int {
        entries.count
    }
    
    var daysSinceLastEntry: Int? {
        guard let lastEntry = entries.first else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: lastEntry.timestamp, to: Date()).day
    }
    
    var entriesThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.timestamp >= weekAgo }.count
    }
}

