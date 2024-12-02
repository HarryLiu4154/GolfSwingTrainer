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

// MARK: - User Loading and Updates
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
}

// MARK: - Delete User
extension UserDataViewModel {
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

        if let image = profileImage {
            do {
                profilePictureURL = try await firebaseService.uploadProfileImage(image: image)
            } catch {
                print("Failed to upload profile image: \(error.localizedDescription)")
                return
            }
        }

        let friends = currentUser.account?.friends ?? []
        let friendRequests = currentUser.account?.friendRequests ?? []

        let account = Account(
            id: currentUser.account?.id ?? UUID(),
            userName: userName,
            profilePictureURL: profilePictureURL,
            playerLevel: playerLevel,
            playerStatus: playerStatus,
            friends: friends,
            friendRequests: friendRequests
        )

        currentUser.account = account
        await updateUser(currentUser)
    }

    /// Remove the account from the user object.
    func removeAccount() async {
        guard let currentUser = user else {
            print("UserDataViewModel: No current user to update.")
            return
        }

        var updatedUser = currentUser
        updatedUser.account = nil
        await updateUser(updatedUser)
    }
}

// MARK: - Friends Management
extension UserDataViewModel {
    /// Add a friend by username.
    func addFriend(by username: String) async {
        guard let currentAccount = user?.account else { return }
        do {
            if let friendAccount = try await firebaseService.fetchAccountByUsername(username: username) {
                try await firebaseService.addFriend(
                    currentUserId: currentAccount.id.uuidString,
                    friendUserId: friendAccount.id.uuidString
                )
                print("Friend added successfully.")
                await loadUser() // Refresh user data
            } else {
                print("User with username '\(username)' not found.")
            }
        } catch {
            print("Failed to add friend: \(error.localizedDescription)")
        }
    }
    
    /// Send a friend request to another user by username.
    func sendFriendRequest(to username: String) async {
        guard let currentAccount = user?.account else { return }
        do {
            if let friendAccount = try await firebaseService.fetchAccountByUsername(username: username) {
                try await firebaseService.sendFriendRequest(
                    to: friendAccount.id.uuidString,
                    from: currentAccount.id.uuidString
                )
                print("Friend request sent successfully.")
            } else {
                print("User with username '\(username)' not found.")
            }
        } catch {
            print("Failed to send friend request: \(error.localizedDescription)")
        }
    }
    
    /// Accept a friend request from another user.
    func acceptFriendRequest(from userId: String) async {
        guard let currentAccount = user?.account else { return }
        do {
            try await firebaseService.acceptFriendRequest(
                currentUserId: currentAccount.id.uuidString,
                from: userId
            )
            print("Friend request accepted.")
            await loadUser() // Refresh user data
        } catch {
            print("Failed to accept friend request: \(error.localizedDescription)")
        }
    }
    
    /// Decline a friend request.
    func declineFriendRequest(from userId: String) async {
        guard let currentAccount = user?.account else { return }
        do {
            try await firebaseService.declineFriendRequest(
                currentAccountId: currentAccount.id.uuidString,
                from: userId
            )
            print("Friend request declined.")
            await loadUser() // Refresh user data
        } catch {
            print("Failed to decline friend request: \(error.localizedDescription)")
        }
    }
    
    /// Remove a friend.
    func removeFriend(friendId: String) async {
        guard let currentAccount = user?.account else { return }
        do {
            try await firebaseService.removeFriend(
                currentUserId: currentAccount.id.uuidString,
                friendUserId: friendId
            )
            print("Friend removed successfully.")
            await loadUser() // Refresh user data
        } catch {
            print("Failed to remove friend: \(error.localizedDescription)")
        }
    }
}
