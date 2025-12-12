//
//  SettingsView.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
// import Inject

struct SettingsView: View {
    // @ObserveInjection var inject
    @Bindable var viewModel: SettingsViewModel
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            if viewModel.isSignedIn {
                signedInView
            } else {
                signInView
            }
        }
        // .enableInjection()
    }
    
    private var signedInView: some View {
        Form {
            Section {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                        .overlay {
                            Text(viewModel.userName?.prefix(1).uppercased() ?? "U")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.userName ?? "User")
                            .font(.headline)
                        Text(viewModel.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            Section("Account") {
                Button(role: .destructive) {
                    viewModel.signOut()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
    
    private var signInView: some View {
        Form {
            Section {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            } header: {
                Text("Sign In")
            } footer: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            
            Section {
                Button {
                    Task {
                        await viewModel.signIn()
                    }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
                
                Button {
                    showSignUp = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Create Account")
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showSignUp) {
            SignUpView(viewModel: viewModel)
        }
    }
}

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SettingsViewModel
    @State private var confirmPassword: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                } header: {
                    Text("Create Account")
                } footer: {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if !confirmPassword.isEmpty && viewModel.password != confirmPassword {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.signUp()
                            if viewModel.isSignedIn {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(
                        viewModel.isLoading ||
                        viewModel.email.isEmpty ||
                        viewModel.password.isEmpty ||
                        confirmPassword.isEmpty ||
                        viewModel.password != confirmPassword
                    )
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}

