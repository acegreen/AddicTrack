//
//  AddictionListView.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
import SwiftData
// import Inject

struct AddictionListView: View {
    // @ObserveInjection var inject
    @Environment(\.modelContext) private var modelContext
    @Bindable var settingsViewModel: SettingsViewModel
    @State private var viewModel = AddictionListViewModel()
    @State private var showAddAddiction = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !settingsViewModel.isSignedIn {
                    SignInRequiredView()
                } else if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.addictions.isEmpty {
                    EmptyStateView {
                        showAddAddiction = true
                    }
                } else {
                    List {
                        ForEach(viewModel.addictions) { addiction in
                            NavigationLink {
                                AddictionDetailView(addiction: addiction)
                            } label: {
                                AddictionRowView(addiction: addiction)
                            }
                        }
                        .onDelete(perform: deleteAddictions)
                    }
                }
            }
            .navigationTitle("My Addictions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddAddiction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(!settingsViewModel.isSignedIn)
                }
            }
            .sheet(isPresented: $showAddAddiction) {
                AddAddictionView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
                viewModel.setCurrentUser(settingsViewModel.currentUser)
            }
            .onChange(of: settingsViewModel.currentUser) { oldValue, newValue in
                viewModel.setCurrentUser(newValue)
            }
        }
        // .enableInjection()
    }
    
    private func deleteAddictions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewModel.deleteAddiction(viewModel.addictions[index])
            }
        }
    }
}

struct AddictionRowView: View {
    let addiction: Addiction
    
    var body: some View {
        HStack {
            Image(systemName: addiction.iconName)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(addiction.name)
                    .font(.headline)
                
                if let description = addiction.desc, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(addiction.totalEntries)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStateView: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Addictions Tracked")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking your journey by adding your first addiction")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                onAddTapped()
            } label: {
                Label("Add Addiction", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct SignInRequiredView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Sign In Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Please sign in to view and track your addictions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    AddictionListView(settingsViewModel: SettingsViewModel())
        .modelContainer(for: [User.self, Addiction.self, AddictionEntry.self], inMemory: true)
}

