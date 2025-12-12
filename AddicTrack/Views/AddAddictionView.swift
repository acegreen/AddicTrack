//
//  AddAddictionView.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
// import Inject

struct AddAddictionView: View {
    // @ObserveInjection var inject
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedColor: String = "#007AFF"
    
    let viewModel: AddictionListViewModel
    
    let colors: [(name: String, hex: String)] = [
        ("Blue", "#007AFF"),
        ("Red", "#FF3B30"),
        ("Green", "#34C759"),
        ("Orange", "#FF9500"),
        ("Purple", "#AF52DE"),
        ("Pink", "#FF2D55"),
        ("Teal", "#5AC8FA"),
        ("Indigo", "#5856D6")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Information") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colors, id: \.hex) { color in
                            ColorOptionView(
                                colorHex: color.hex,
                                isSelected: selectedColor == color.hex
                            ) {
                                selectedColor = color.hex
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Addiction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addAddiction()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        // .enableInjection()
    }
    
    private func addAddiction() {
        viewModel.addAddiction(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespaces),
            colorHex: selectedColor
        )
        dismiss()
    }
}

struct ColorOptionView: View {
    let colorHex: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let viewModel = AddictionListViewModel()
    return AddAddictionView(viewModel: viewModel)
}

