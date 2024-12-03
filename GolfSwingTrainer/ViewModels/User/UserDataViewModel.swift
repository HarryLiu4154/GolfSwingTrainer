//
//  UserDataViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation
import FirebaseAuth
import UIKit

/// Unified ViewModel that handles User-data related operations using CoreDataService and FirebaseService for synchronized functionality.
@MainActor
class UserDataViewModel: ObservableObject {
    // MARK: - Properties
    @Published var user: User? // Current user model

    // Services
    let coreDataService: CoreDataService
    let firebaseService: FirebaseService
    let auth: Auth

    // MARK: - Initializer
    init(coreDataService: CoreDataService, firebaseService: FirebaseService, auth: Auth = Auth.auth()) {
        self.coreDataService = coreDataService
        self.firebaseService = firebaseService
        self.auth = auth

        Task {
            await loadUser()
        }
    }
}

// MARK: - User Management
extension UserDataViewModel {
    /// Load the user from Core Data or Firebase.
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

    /// Update the entire user object in Firebase and Core Data.
    func updateUser(_ updatedUser: User) async {
        self.user = updatedUser
        coreDataService.saveUser(updatedUser)
        do {
            try await firebaseService.saveUser(updatedUser)
        } catch {
            print("UserDataViewModel: Failed to update user in Firebase: \(error.localizedDescription)")
        }
    }
    
    ///Delete whole user
    func deleteUser() async {
        guard let currentUser = user else {
            print("UserDataViewModel: No user available to delete.")
            return
        }

        // Delete all posts by the user (if needed)
        let feedViewModel = FeedViewModel() // Assuming FeedViewModel exists
        await feedViewModel.deleteAllPostsByUser(userUID: currentUser.uid)

        // Delete user from Core Data
        coreDataService.deleteUser(currentUser)

        // Delete user from Firebase
        do {
            try await firebaseService.deleteUser(uid: currentUser.uid)
            self.user = nil // Clear local user state
            print("UserDataViewModel: User deleted successfully.")
        } catch {
            print("UserDataViewModel: Failed to delete user: \(error.localizedDescription)")
        }
    }
}

// MARK: - User Attributes Management
extension UserDataViewModel {
    /// Update user-specific attributes such as height, weight, etc.
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

        var updatedUser = currentUser
        updatedUser.preferredMeasurement = preferredMeasurement
        updatedUser.height = height
        updatedUser.weight = weight
        updatedUser.birthDate = birthDate
        updatedUser.gender = gender
        updatedUser.dominantHand = dominantHand

        await updateUser(updatedUser)
    }
    
    ///Helper Method to Retrieve User Attributes
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

// MARK: - Account Management
extension UserDataViewModel {
    /// Update account data such as username, profile picture, player level, and player status.
    func updateAccount(
        userName: String? = nil,
        profileImage: UIImage? = nil,
        playerLevel: String? = nil,
        playerStatus: String? = nil
    ) async {
        guard var currentUser = user, var currentAccount = currentUser.firestoreAccount else { return }
        
        if let userName = userName { currentAccount.userName = userName }
        if let playerLevel = playerLevel { currentAccount.playerLevel = playerLevel }
        if let playerStatus = playerStatus { currentAccount.playerStatus = playerStatus }
        
        if let image = profileImage {
            do {
                currentAccount.profilePictureURL = try await firebaseService.uploadProfileImage(image: image)
            } catch {
                print("Failed to upload profile image: \(error.localizedDescription)")
                return
            }
        }
        
        do {
            try await firebaseService.saveAccount(currentAccount)
            currentUser.firestoreAccount = currentAccount
            user = currentUser
        } catch {
            print("Failed to update account: \(error.localizedDescription)")
        }
    }
    func fetchOrCreateAccount(for uid: String) async {
        guard var currentUser = user else { return }
        
        do {
            // Try to fetch the existing account
            if let fetchedAccount = try await firebaseService.fetchAccount(for: uid) {
                currentUser.firestoreAccount = fetchedAccount
            } else {
                // Dynamically generate a unique username if needed
                let baseUserName = currentUser.fullName.replacingOccurrences(of: " ", with: "").lowercased()
                var newUserName = baseUserName
                var isUnique = false
                var counter = 1
                
                // Check for username uniqueness
                while !isUnique {
                    if try await firebaseService.isUserNameAvailable(newUserName) {
                        isUnique = true
                    } else {
                        newUserName = "\(baseUserName)\(counter)"
                        counter += 1
                    }
                }
                
                // Create a new account
                let newAccount = Account(
                    id: UUID(),
                    ownerUid: uid, // The Firebase UID of the user creating the account
                    userName: newUserName, // Unique username, ensure validated for uniqueness
                    profilePictureURL: nil, // Default to nil; can be updated later
                    playerLevel: "Beginner", // Default player level
                    playerStatus: "Just for fun", // Default player status
                    friends: [], // Empty list as the user starts with no friends
                    friendRequests: FriendRequests(incoming: [], outgoing: []) // No requests at creation
                )
                
                // Save the new account to Firestore
                try await firebaseService.saveAccount(newAccount)
                
                // Update the user with the new account
                currentUser.firestoreAccount = newAccount
            }
            
            // Update the local user state
            user = currentUser
        } catch {
            print("Failed to fetch or create account: \(error.localizedDescription)")
        }
        
    }
    /// Deletes the user's account without deleting the user itself.
    func deleteAccount() async {
        guard var currentUser = user, let account = currentUser.firestoreAccount else {
            print("UserDataViewModel: No account to delete.")
            return
        }

        do {
            // Remove the account from Firebase
            try await firebaseService.deleteAccount(userName: account.userName)

            // Clear the account locally
            currentUser.firestoreAccount = nil
            user = currentUser
            
            print("UserDataViewModel: Account deleted successfully.")
        } catch {
            print("UserDataViewModel: Failed to delete account: \(error.localizedDescription)")
        }
    }
}

// MARK: - Friends Management
extension UserDataViewModel {
    /// Send a friend request to another user.
    func sendFriendRequest(to recipientUserName: String) async {
        guard let senderUserName = user?.firestoreAccount?.userName else { return }
        do {
            try await firebaseService.sendFriendRequest(from: senderUserName, to: recipientUserName)
            print("Friend request sent.")
        } catch {
            print("Failed to send friend request: \(error.localizedDescription)")
        }
    }
    
    /// Accept a friend request from another user.
    func acceptFriendRequest(from senderUserName: String) async {
        guard let recipientUserName = user?.firestoreAccount?.userName else { return }
        do {
            try await firebaseService.acceptFriendRequest(recipientUserName: recipientUserName, senderUserName: senderUserName)
            print("Friend request accepted.")
        } catch {
            print("Failed to accept friend request: \(error.localizedDescription)")
        }
    }
    
    /// Decline a friend request from another user.
    func declineFriendRequest(from senderUserName: String) async {
        guard let recipientUserName = user?.firestoreAccount?.userName else { return }
        do {
            try await firebaseService.declineFriendRequest(recipientUserName: recipientUserName, senderUserName: senderUserName)
            print("Friend request declined.")
        } catch {
            print("Failed to decline friend request: \(error.localizedDescription)")
        }
    }
}
