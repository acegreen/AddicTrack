//
//  AddEntryView.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
// import Inject

struct AddEntryView: View {
    // @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    let addiction: Addiction
    let viewModel: AddictionDetailViewModel
    
    @State private var entryViewModel = AddEntryViewModel()
    @State private var showIntensityPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Date & Time") {
                    DatePicker("When", selection: $entryViewModel.selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Details") {
                    TextField("Notes (Optional)", text: $entryViewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Toggle("Add Intensity", isOn: $showIntensityPicker)
                    
                    if showIntensityPicker {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Intensity: \(entryViewModel.intensity ?? 5)/10")
                                .font(.subheadline)
                            
                            Slider(
                                value: Binding(
                                    get: { Double(entryViewModel.intensity ?? 5) },
                                    set: { entryViewModel.intensity = Int($0) }
                                ),
                                in: 1...10,
                                step: 1
                            )
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
        }
        // .enableInjection()
    }
    
    private func saveEntry() {
        viewModel.addEntry(
            notes: entryViewModel.notes.isEmpty ? nil : entryViewModel.notes,
            intensity: showIntensityPicker ? entryViewModel.intensity : nil,
            timestamp: entryViewModel.selectedDate
        )
        dismiss()
    }
}

#Preview {
    let addiction = Addiction(name: "Smoking")
    let viewModel = AddictionDetailViewModel(addiction: addiction)
    return AddEntryView(addiction: addiction, viewModel: viewModel)
}

