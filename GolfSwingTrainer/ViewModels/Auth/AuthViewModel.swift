//
//  LoginViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//  firebase tutorial -> https://www.youtube.com/watch?v=q-9lx7aSWcc&ab_channel=Firebase

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Firebase

protocol AuthenticationFormProtocol{
    var formIsValid: Bool {get}
}
@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? // Helps determine if user is logged in or not
    @Published var currentUser: User?

    private let _userDataViewModel: UserDataViewModel
    
    @AppStorage("isUserSetupComplete") var isUserSetupComplete: Bool = false // Tracks setup completion
    
    var userDataViewModel: UserDataViewModel {
        _userDataViewModel
    }
    
    init(userDataViewModel: UserDataViewModel) {
        self._userDataViewModel = userDataViewModel
        self.userSession = Auth.auth().currentUser
        
        Task {
            await userDataViewModel.loadUser()
            self.currentUser = userDataViewModel.user
        }
    }
    
    // Sign in
    func signIn(withEmail email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
        await userDataViewModel.loadUser()
        self.currentUser = userDataViewModel.user
    }

    
    // Create user
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid // Firebase UID is non-optional
            self.userSession = result.user
            
            // Create the user object for storage
            let newUser = User(
                id: UUID(), // Generate a new UUID for Core Data
                uid: uid, // Use the Firebase UID
                fullName: fullName,
                email: email,
                birthDate: Date(), // Default values
                dominantHand: "",
                gender: "",
                height: 0,
                preferredMeasurement: "Metric",
                weight: 0
            )
            
            // Save the user to Core Data and Firebase
            await userDataViewModel.updateUser(newUser)
            self.currentUser = newUser
            print("AuthViewModel: User successfully created and stored.")
            isUserSetupComplete = false //reset setup flag
        } catch let error as NSError {
            print("AuthViewModel: Failed to create user: \(error.localizedDescription)")
            throw error
        }
    }

    
    // Sign out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            print("AuthViewModel: Signed out successfully.")
        } catch {
            print("AuthViewModel: Failed to sign out: \(error)")
        }
    }
    
    // Delete account
    func deleteAccount() async {
        guard (userSession?.uid) != nil else { return }
        
        await _userDataViewModel.deleteUser() // Ensure the UserDataViewModel is updated
        do {
            try await Auth.auth().currentUser?.delete()
            self.userSession = nil
            self.currentUser = nil
            print("AuthViewModel: Account deleted successfully.")
        } catch {
            print("AuthViewModel: Failed to delete account: \(error)")
        }
    }
}
