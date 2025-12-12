//
//  AddictionListViewModel.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class AddictionListViewModel {
    var addictions: [Addiction] = []
    var isLoading = false
    var errorMessage: String?
    
    private var modelContext: ModelContext?
    private var currentUser: User?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func setCurrentUser(_ user: User?) {
        self.currentUser = user
        loadAddictions()
    }
    
    func loadAddictions() {
        guard let modelContext = modelContext else { return }
        guard let currentUser = currentUser else {
            addictions = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Use the relationship directly - fetch all addictions and filter by user relationship
        // SwiftData predicates have limitations with optional relationships, so we'll use the inverse relationship
        let descriptor = FetchDescriptor<Addiction>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let allAddictions = try modelContext.fetch(descriptor)
            // Filter by current user manually since predicate with optional relationships is problematic
            addictions = allAddictions.filter { $0.user?.id == currentUser.id }
            isLoading = false
        } catch {
            errorMessage = "Failed to load addictions: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func deleteAddiction(_ addiction: Addiction) {
        guard let modelContext = modelContext else { return }
        
        withAnimation {
            modelContext.delete(addiction)
            loadAddictions()
        }
    }
    
    func addAddiction(name: String, description: String?, colorHex: String) {
        guard let modelContext = modelContext else { return }
        guard let currentUser = currentUser else { return }
        
        let newAddiction = Addiction(name: name, desc: description, colorHex: colorHex, user: currentUser)
        modelContext.insert(newAddiction)
        
        // Add to user's addictions array
        if currentUser.addictions == nil {
            currentUser.addictions = []
        }
        currentUser.addictions?.append(newAddiction)
        
        loadAddictions()
    }
}

