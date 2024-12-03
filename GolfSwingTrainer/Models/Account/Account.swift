//
//  Account.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-03.
//

import Foundation
import CoreData
import UIKit

// MARK: - Account Model
struct Account: Identifiable, Codable, Hashable {
    let id: UUID // Unique identifier for the account
    var ownerUid: String
    var userName: String // Unique username for the user
    var profilePictureURL: String? // Optional profile picture URL
    var playerLevel: String // Player level (Beginner, Intermediate, Amateur, Expert)
    var playerStatus: String // Player status (Just for fun, Trainer, Competitor/Professional)
    var friends: [Friend] // List of friends
    var friendRequests: FriendRequests // Friend request details (incoming and outgoing)
}
/// AccountEntity Extension (Core Data)
extension AccountEntity {
    func toAccount() -> Account {
        return Account(
            id: self.id ?? UUID(),
            ownerUid: self.ownerUid ?? "",
            userName: self.userName ?? "",
            profilePictureURL: self.profilePictureURL,
            playerLevel: self.playerLevel ?? "",
            playerStatus: self.playerStatus ?? "",
            friends: (self.friends as? Set<FriendEntity>)?.map { $0.toFriend() } ?? [],
            friendRequests: self.friendRequests?.toFriendRequests() ?? FriendRequests(incoming: [], outgoing: [])
        )
    }

    func update(from account: Account, context: NSManagedObjectContext) {
        self.id = account.id
        self.ownerUid = account.ownerUid
        self.userName = account.userName
        self.profilePictureURL = account.profilePictureURL
        self.playerLevel = account.playerLevel
        self.playerStatus = account.playerStatus

        // Update friends
        let friendsSet = self.mutableSetValue(forKey: "friends")
        friendsSet.removeAllObjects()
        for friend in account.friends {
            let friendEntity = FriendEntity(context: context)
            friendEntity.update(from: friend)
            friendsSet.add(friendEntity)
        }

        // Update friendRequests
        if let existingFriendRequestsEntity = self.friendRequests {
            existingFriendRequestsEntity.update(from: account.friendRequests, context: context)
        } else {
            let newFriendRequestsEntity = FriendRequestsEntity(context: context)
            newFriendRequestsEntity.update(from: account.friendRequests, context: context)
            self.friendRequests = newFriendRequestsEntity
        }

        do {
            try context.save()
        } catch {
            print("Failed to save AccountEntity: \(error.localizedDescription)")
        }
    }
}
//MARK: - Friend Model
struct Friend: Identifiable, Codable, Hashable {
    let id: String // uid of the friend
    let userName: String // Friend's username
    var profilePictureURL: String? // Optional profile picture
    var playerLevel: String // Friend's player level
}

extension FriendEntity {
    func toFriend() -> Friend {
        return Friend(
            id: self.id ?? "",
            userName: self.userName ?? "",
            profilePictureURL: self.profilePictureURL,
            playerLevel: self.playerLevel ?? ""
        )
    }

    func update(from friend: Friend) {
        self.id = friend.id
        self.userName = friend.userName
        self.profilePictureURL = friend.profilePictureURL
        self.playerLevel = friend.playerLevel
    }
}


// MARK: - FriendRequests Model
struct FriendRequests: Codable, Hashable {
    var incoming: [String] // Usernames of incoming requests
    var outgoing: [String] // Usernames of outgoing requests
}

extension FriendRequestsEntity {
    func toFriendRequests() -> FriendRequests {
        return FriendRequests(
            incoming: self.incoming as? [String] ?? [],
            outgoing: self.outgoing as? [String] ?? []
        )
    }

    func update(from friendRequests: FriendRequests, context: NSManagedObjectContext) {
        // Convert Swift arrays to NSSet
        self.incoming = NSSet(array: friendRequests.incoming)
        self.outgoing = NSSet(array: friendRequests.outgoing)
    }
}
