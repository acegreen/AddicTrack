//
//  AddictionDetailView.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
import SwiftData
// import Inject

struct AddictionDetailView: View {
    // @ObserveInjection var inject
    @Environment(\.modelContext) private var modelContext
    let addiction: Addiction
    @State private var viewModel: AddictionDetailViewModel
    @State private var showAddEntry = false
    
    init(addiction: Addiction) {
        self.addiction = addiction
        self._viewModel = State(initialValue: AddictionDetailViewModel(addiction: addiction))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Statistics Section
                StatisticsSection(viewModel: viewModel)
                
                // Entries Section
                EntriesSection(
                    entries: viewModel.entries,
                    onDelete: { entry in
                        viewModel.deleteEntry(entry)
                    }
                )
            }
            .padding()
        }
        .navigationTitle(addiction.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddEntry = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddEntry) {
            AddEntryView(addiction: addiction, viewModel: viewModel)
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        // .enableInjection()
    }
}

struct StatisticsSection: View {
    let viewModel: AddictionDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Entries",
                    value: "\(viewModel.totalEntries)",
                    icon: "list.number"
                )
                
                StatCard(
                    title: "This Week",
                    value: "\(viewModel.entriesThisWeek)",
                    icon: "calendar"
                )
                
                if let daysSince = viewModel.daysSinceLastEntry {
                    StatCard(
                        title: "Days Since",
                        value: "\(daysSince)",
                        icon: "clock"
                    )
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EntriesSection: View {
    let entries: [AddictionEntry]
    let onDelete: (AddictionEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.headline)
            
            if entries.isEmpty {
                Text("No entries yet. Tap + to add your first entry.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(entries) { entry in
                    EntryRowView(entry: entry)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                onDelete(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

struct EntryRowView: View {
    let entry: AddictionEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.timestamp, style: .date)
                    .font(.headline)
                
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let intensity = entry.intensity {
                HStack(spacing: 4) {
                    Image(systemName: "gauge")
                    Text("\(intensity)/10")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        
        if let notes = entry.notes, !notes.isEmpty {
            Text(notes)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top, -8)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Addiction.self, AddictionEntry.self, configurations: config)
    let addiction = Addiction(name: "Smoking", desc: "Cigarettes")
    
    NavigationStack {
        AddictionDetailView(addiction: addiction)
    }
    .modelContainer(container)
}

