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
    @State private var selectedIcon: String = "heart.circle.fill"
    
    let viewModel: AddictionListViewModel
    
    let icons: [(name: String, symbol: String)] = [
        // Substances & Health
        ("Pill", "pills.fill"),
        ("Syringe", "syringe.fill"),
        ("Drop", "drop.fill"),
        ("Smoke", "smoke.fill"),
        ("Cigarette", "cigarette.fill"),
        ("Flame", "flame.fill"),
        ("Heart", "heart.circle.fill"),
        ("Warning", "exclamationmark.triangle.fill"),
        ("Bandage", "bandage.fill"),
        
        // Alcohol & Drinks
        ("Wine", "wineglass.fill"),
        ("Beer", "mug.fill"),
        ("Cup", "cup.and.saucer.fill"),
        ("Bottle", "waterbottle.fill"),
        ("Cocktail", "wineglass"),
        
        // Technology & Digital
        ("Phone", "phone.fill"),
        ("Game Controller", "gamecontroller.fill"),
        ("TV", "tv.fill"),
        ("Computer", "desktopcomputer"),
        ("Laptop", "laptopcomputer"),
        ("Tablet", "ipad"),
        ("Headphones", "headphones"),
        ("Camera", "camera.fill"),
        ("Video", "video.fill"),
        ("Music", "music.note"),
        ("App", "app.fill"),
        ("Browser", "safari.fill"),
        ("Social Media", "person.2.fill"),
        ("Message", "message.fill"),
        ("Email", "envelope.fill"),
        
        // Shopping & Spending
        ("Credit Card", "creditcard.fill"),
        ("Shopping Cart", "cart.fill"),
        ("Bag", "bag.fill"),
        ("Wallet", "wallet.pass.fill"),
        ("Dollar", "dollarsign.circle.fill"),
        ("Coins", "bitcoinsign.circle.fill"),
        ("Tag", "tag.fill"),
        ("Receipt", "doc.text.fill"),
        
        // Food & Eating
        ("Fork & Knife", "fork.knife"),
        ("Pizza", "takeoutbag.and.cup.and.straw.fill"),
        ("Candy", "candybar"),
        ("Donut", "birthday.cake.fill"),
        ("Fast Food", "takeoutbag.fill"),
        
        // Gambling & Games
        ("Dice", "dice.fill"),
        ("Cards", "suit.spade.fill"),
        ("Slot Machine", "gamecontroller"),
        ("Trophy", "trophy.fill"),
        ("Star", "star.fill"),
        
        // Social & Relationships
        ("Person", "person.fill"),
        ("People", "person.2.fill"),
        ("Group", "person.3.fill"),
        ("Heart Broken", "heart.slash.fill"),
        ("Handshake", "hand.raised.fill"),
        
        // Work & Stress
        ("Briefcase", "briefcase.fill"),
        ("Document", "doc.fill"),
        ("Clock", "clock.fill"),
        ("Timer", "timer"),
        ("Calendar", "calendar"),
        ("Alarm", "alarm.fill"),
        
        // Exercise & Activities
        ("Running", "figure.run"),
        ("Walking", "figure.walk"),
        ("Bike", "bicycle"),
        ("Car", "car.fill"),
        ("Gym", "dumbbell.fill"),
        
        // Sleep & Rest
        ("Bed", "bed.double.fill"),
        ("Moon", "moon.fill"),
        ("Sun", "sun.max.fill"),
        
        // Emotions & Mental
        ("Lightning", "bolt.fill"),
        ("Brain", "brain.head.profile"),
        ("Eye", "eye.fill"),
        ("Mind", "brain"),
        
        // General
        ("Circle", "circle.fill"),
        ("Square", "square.fill"),
        ("Triangle", "triangle.fill"),
        ("Diamond", "diamond.fill"),
        ("Hexagon", "hexagon.fill"),
        ("Flag", "flag.fill"),
        ("Bookmark", "bookmark.fill"),
        ("Pin", "pin.fill"),
        ("Lock", "lock.fill"),
        ("Key", "key.fill"),
        ("Bell", "bell.fill"),
        ("Chart", "chart.bar.fill"),
        ("Graph", "chart.line.uptrend.xyaxis")
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
                
                Section("Icon") {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                            ForEach(icons, id: \.symbol) { icon in
                                IconOptionView(
                                    iconName: icon.symbol,
                                    isSelected: selectedIcon == icon.symbol
                                ) {
                                    selectedIcon = icon.symbol
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 400)
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
            iconName: selectedIcon
        )
        dismiss()
    }
}

struct IconOptionView: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .frame(width: 60, height: 60)
                
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .primary)
                
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                                .background(Color.white.clipShape(Circle()))
                        }
                        Spacer()
                    }
                    .frame(width: 60, height: 60)
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

