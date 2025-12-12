//
//  User.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftData

@Model
final class User: Identifiable {
    var id: UUID
    var email: String
    var name: String?
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Addiction.user)
    var addictions: [Addiction]?
    
    init(email: String, name: String? = nil) {
        self.id = UUID()
        self.email = email
        self.name = name
        self.createdAt = Date()
        self.addictions = []
    }
}

