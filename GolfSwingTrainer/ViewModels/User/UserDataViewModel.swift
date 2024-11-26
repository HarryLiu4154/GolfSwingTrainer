//
//  UserDataViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation
import FirebaseAuth

///Unified ViewModel that handles User-data related operations using CoreDataService and FirebaseService for syncronized funionality.
@MainActor
class UserDataViewModel: ObservableObject {
    @Published var user: User? // Current user model
    
    //Services
    let coreDataService: CoreDataService
    let firebaseService: FirebaseService
    let auth: Auth
    
    init(coreDataService: CoreDataService, firebaseService: FirebaseService, auth: Auth = Auth.auth()) {
        self.coreDataService = coreDataService
        self.firebaseService = firebaseService
        self.auth = auth
        
        Task {
            await loadUser()
        }
    }
    
    // MARK: - Load User Data
    func loadUser() async {
        guard let uid = auth.currentUser?.uid else {
            print("UserDataViewModel: No authenticated user.")
            return
        }

        if let coreDataUser = coreDataService.fetchUser(by: uid) {
            self.user = coreDataUser
        } else {
            do {
                if let firebaseUser = try await firebaseService.fetchUser(uid: uid) {
                    self.user = firebaseUser
                    coreDataService.saveUser(firebaseUser) // Sync to Core Data
                } else {
                    print("UserDataViewModel: No user found in Firebase.")
                }
            } catch {
                print("UserDataViewModel: Failed to fetch user from Firebase: \(error)")
            }
        }
    }
    
    // MARK: - Delete User
    func deleteUser() async {
        guard let user = self.user else {
            print("UserDataViewModel: No user available to delete.")
            return
        }
        
        // Delete from Core Data
        coreDataService.deleteUser(user)
        
        // Delete from Firebase
        do {
            try await firebaseService.deleteUser(uid: user.id.uuidString)
            self.user = nil // Clear local user data
        } catch {
            print("UserDataViewModel: Failed to delete user from Firebase: \(error)")
        }
    }
    
    // MARK: - Save Updated User Attributes
    func updateUserAttributes(
        preferredMeasurement: String,
        height: Int,
        weight: Int,
        birthDate: Date,
        gender: String,
        dominantHand: String
    ) async {
        guard let currentUser = user else {
            print("UserDataViewModel: No current user to update.")
            return
        }

        // Update the user object
        var updatedUser = currentUser
        updatedUser.preferredMeasurement = preferredMeasurement
        updatedUser.height = height
        updatedUser.weight = weight
        updatedUser.birthDate = birthDate
        updatedUser.gender = gender
        updatedUser.dominantHand = dominantHand

        // Save changes to Firebase and Core Data
        await updateUser(updatedUser)
    }
    
    // MARK: - Update Entire User
    func updateUser(_ updatedUser: User) async {
        self.user = updatedUser // Update local state
        
        // Save to Core Data
        coreDataService.saveUser(updatedUser)
        
        // Save to Firebase
        do {
            try await firebaseService.saveUser(updatedUser)
        } catch {
            print("UserDataViewModel: Failed to update user in Firebase: \(error)")
        }
    }
    
    // MARK: - Helper Method to Populate Fields
    func getUserAttributes() -> (
        preferredMeasurement: String,
        height: Int,
        weight: Int,
        birthDate: Date,
        gender: String,
        dominantHand: String
    ) {
        return (
            user?.preferredMeasurement ?? "Metric",
            user?.height ?? 170,
            user?.weight ?? 70,
            user?.birthDate ?? Date(),
            user?.gender ?? "Male",
            user?.dominantHand ?? "Right"
        )
    }
}
