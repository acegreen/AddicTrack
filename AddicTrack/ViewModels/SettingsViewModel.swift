//
//  SettingsViewModel.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    var isSignedIn = false
    var email: String = ""
    var password: String = ""
    var isLoading = false
    var errorMessage: String?
    var userName: String?
    var currentUser: User?
    
    private var modelContext: ModelContext?
    
    init() {
        // Check if user is already signed in (e.g., from UserDefaults or Keychain)
        checkSignInStatus()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        checkSignInStatus()
    }
    
    private func checkSignInStatus() {
        guard let modelContext = modelContext else { return }
        
        // Check for existing session
        if let savedEmail = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = savedEmail
            self.userName = UserDefaults.standard.string(forKey: "userName")
            
            // Try to find existing user in database
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate<User> { user in
                    user.email == savedEmail
                }
            )
            
            do {
                let users = try modelContext.fetch(descriptor)
                if let user = users.first {
                    self.currentUser = user
                    self.isSignedIn = true
                }
            } catch {
                // User not found in database, will create on next sign in
            }
        }
    }
    
    func signIn() async {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            isLoading = false
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        // Simulate API call - replace with actual authentication
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // For demo purposes, accept any email/password
            // In production, replace with actual authentication API call
            await MainActor.run {
                guard let modelContext = self.modelContext else {
                    self.errorMessage = "Database not initialized"
                    self.isLoading = false
                    return
                }
                
                // Find or create user
                let descriptor = FetchDescriptor<User>(
                    predicate: #Predicate<User> { user in
                        user.email == self.email
                    }
                )
                
                do {
                    let users = try modelContext.fetch(descriptor)
                    if let existingUser = users.first {
                        self.currentUser = existingUser
                    } else {
                        // Create new user
                        let newUser = User(email: self.email, name: self.userName)
                        modelContext.insert(newUser)
                        self.currentUser = newUser
                    }
                    
                    self.isSignedIn = true
                    self.userName = self.email.components(separatedBy: "@").first?.capitalized
                    self.password = "" // Clear password
                    
                    // Save to UserDefaults (in production, use Keychain)
                    UserDefaults.standard.set(self.email, forKey: "userEmail")
                    UserDefaults.standard.set(self.userName, forKey: "userName")
                    
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Failed to create user: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Sign in failed. Please try again."
                self.isLoading = false
            }
        }
    }
    
    func signOut() {
        isSignedIn = false
        email = ""
        password = ""
        userName = nil
        currentUser = nil
        errorMessage = nil
        
        // Clear saved data
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
    }
    
    func signUp() async {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            isLoading = false
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        // Simulate API call - replace with actual sign up
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // For demo purposes, accept any email/password
            // In production, replace with actual sign up API call
            await MainActor.run {
                guard let modelContext = self.modelContext else {
                    self.errorMessage = "Database not initialized"
                    self.isLoading = false
                    return
                }
                
                // Check if user already exists
                let descriptor = FetchDescriptor<User>(
                    predicate: #Predicate<User> { user in
                        user.email == self.email
                    }
                )
                
                do {
                    let users = try modelContext.fetch(descriptor)
                    if users.first != nil {
                        self.errorMessage = "An account with this email already exists"
                        self.isLoading = false
                        return
                    }
                    
                    // Create new user
                    let newUser = User(email: self.email, name: self.userName)
                    modelContext.insert(newUser)
                    self.currentUser = newUser
                    
                    self.isSignedIn = true
                    self.userName = self.email.components(separatedBy: "@").first?.capitalized
                    self.password = "" // Clear password
                    
                    // Save to UserDefaults (in production, use Keychain)
                    UserDefaults.standard.set(self.email, forKey: "userEmail")
                    UserDefaults.standard.set(self.userName, forKey: "userName")
                    
                    self.isLoading = false
                } catch {
                    self.errorMessage = "Failed to create user: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Sign up failed. Please try again."
                self.isLoading = false
            }
        }
    }
}

