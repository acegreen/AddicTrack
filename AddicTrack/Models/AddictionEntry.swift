//
//  AddictionEntry.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftData

@Model
final class AddictionEntry: Identifiable {
    var id: UUID
    var timestamp: Date
    var notes: String?
    var intensity: Int? // Optional: 1-10 scale for intensity/severity
    var addiction: Addiction?
    
    init(timestamp: Date = Date(), notes: String? = nil, intensity: Int? = nil, addiction: Addiction? = nil) {
        self.id = UUID()
        self.timestamp = timestamp
        self.notes = notes
        self.intensity = intensity
        self.addiction = addiction
    }
}

