//
//  Addiction.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftData

@Model
final class Addiction: Identifiable {
    var id: UUID
    var name: String
    var desc: String?
    var createdAt: Date
    var colorHex: String // For UI customization
    @Relationship(deleteRule: .cascade, inverse: \AddictionEntry.addiction)
    var entries: [AddictionEntry]?
    var user: User?
    
    init(name: String, desc: String? = nil, colorHex: String = "#007AFF", user: User? = nil) {
        self.id = UUID()
        self.name = name
        self.desc = desc
        self.createdAt = Date()
        self.colorHex = colorHex
        self.entries = []
        self.user = user
    }
    
    // Computed properties for statistics
    var totalEntries: Int {
        entries?.count ?? 0
    }
    
    var lastEntryDate: Date? {
        entries?.max(by: { $0.timestamp < $1.timestamp })?.timestamp
    }
    
    var streakDays: Int {
        guard let entries = entries, !entries.isEmpty else { return 0 }
        // Calculate current streak of days without entry
        // This is a simplified version - you might want to enhance this
        return 0 // Placeholder
    }
}

