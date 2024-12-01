//
//  UserDataViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation
import FirebaseAuth
import UIKit

///Unified ViewModel that handles User-data related operations using CoreDataService and FirebaseService for syncronized funionality.
@MainActor
class UserDataViewModel: ObservableObject {
    //Models
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
    // MARK: - Manage Account Data
    func updateAccountData(
        userName: String,
        profileImage: UIImage?,
        playerLevel: String,
        playerStatus: String
    ) async {
        guard var currentUser = user else {
            print("UserDataViewModel: No current user to update.")
            return
        }

        var profilePictureURL = currentUser.account?.profilePictureURL

        // Upload the profile image if provided
        if let image = profileImage {
            do {
                print("Uploading image...")
                profilePictureURL = try await firebaseService.uploadProfileImage(image: image)
                print("Image uploaded successfully: \(profilePictureURL ?? "nil")")
            } catch {
                print("Failed to upload profile image: \(error.localizedDescription)")
                return
            }
        }

        // Create or update the account
        let account = Account(
            id: currentUser.account?.id ?? UUID(),
            userName: userName,
            profilePictureURL: profilePictureURL,
            playerLevel: playerLevel,
            playerStatus: playerStatus
        )

        currentUser.account = account
        await updateUser(currentUser)

        print("Updated account saved with profilePictureURL: \(profilePictureURL ?? "nil")")
    }


    
    func removeAccount() async {
        guard var currentUser = user else {
            print("UserDataViewModel: No current user to update.")
            return
        }
        
        currentUser.account = nil
        await updateUser(currentUser)
    }
    
    // MARK: - Update Entire User
    func updateUser(_ updatedUser: User) async {
        self.user = updatedUser // Update local state
        
        // Save to Core Data
        coreDataService.saveUser(updatedUser)
        
        // Save to Firestore
        do {
            try await firebaseService.saveUser(updatedUser)
            print("User updated successfully in Firestore.")
        } catch {
            print("UserDataViewModel: Failed to update user in Firestore: \(error.localizedDescription)")
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
    // MARK: - Helper Method to Populate Account Attributes
    func getAccountAttributes() -> (
        userName: String?,
        profilePictureURL: String?,
        playerLevel: String?,
        playerStatus: String?
    ) {
        return (
            user?.account?.userName,
            user?.account?.profilePictureURL,
            user?.account?.playerLevel,
            user?.account?.playerStatus
        )
    }
}
