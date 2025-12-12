//
//  AddEntryViewModel.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftUI

@Observable
final class AddEntryViewModel {
    var selectedDate = Date()
    var notes: String = ""
    var intensity: Int? = nil
    var showIntensityPicker = false
    
    func reset() {
        selectedDate = Date()
        notes = ""
        intensity = nil
        showIntensityPicker = false
    }
}

