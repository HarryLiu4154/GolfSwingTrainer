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
        userName: String,
        profileImage: UIImage? = nil,
        playerLevel: String,
        playerStatus: String
    ) async {
        guard var currentUser = user else { return }

        var account = currentUser.firestoreAccount ?? Account(
            id: UUID(),
            ownerUid: currentUser.uid,
            userName: userName,
            profilePictureURL: nil,
            playerLevel: playerLevel,
            playerStatus: playerStatus,
            friends: [],
            friendRequests: FriendRequests(incoming: [], outgoing: [])
        )

        account.playerLevel = playerLevel
        account.playerStatus = playerStatus

        if let profileImage = profileImage {
            do {
                account.profilePictureURL = try await firebaseService.uploadProfileImage(image: profileImage)
            } catch {
                print("Failed to upload profile image: \(error.localizedDescription)")
                return
            }
        }

        do {
            try await firebaseService.saveAccount(account, forUser: currentUser.uid)
            currentUser.firestoreAccount = account
            user = currentUser
        } catch {
            print("Failed to update account: \(error.localizedDescription)")
        }
    }
    

    func fetchOrCreateAccount(for uid: String) async {
        guard var currentUser = user else { return }

        do {
            if let fetchedAccount = try await firebaseService.fetchAccount(for: uid) {
                currentUser.firestoreAccount = fetchedAccount
            } else {
                let baseUserName = currentUser.fullName.replacingOccurrences(of: " ", with: "").lowercased()
                var newUserName = baseUserName
                var isUnique = false
                var counter = 1
                
                while !isUnique {
                    if try await firebaseService.isUserNameAvailable(newUserName) {
                        isUnique = true
                    } else {
                        newUserName = "\(baseUserName)\(counter)"
                        counter += 1
                    }
                }

                let newAccount = Account(
                    id: UUID(),
                    ownerUid: uid,
                    userName: newUserName,
                    profilePictureURL: nil,
                    playerLevel: "Beginner",
                    playerStatus: "Just for fun",
                    friends: [],
                    friendRequests: FriendRequests(incoming: [], outgoing: [])
                )

                try await firebaseService.saveAccount(newAccount, forUser: uid)
                currentUser.firestoreAccount = newAccount
            }

            user = currentUser
        } catch {
            print("Failed to fetch or create account: \(error.localizedDescription)")
        }
    }

    /// Deletes the user's account without deleting the user itself.
    func deleteAccount() async {
        guard var currentUser = user, let account = currentUser.firestoreAccount else {
            print("No account to delete.")
            return
        }
        
        do {
            try await firebaseService.deleteAccount(userName: account.userName, forUser: currentUser.uid)
            currentUser.firestoreAccount = nil
            user = currentUser
            print("Account deleted successfully.")
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
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
