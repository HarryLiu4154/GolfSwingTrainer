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
    var userName: String // Unique username for the user
    var profilePictureURL: String? // Optional profile picture URL
    var playerLevel: String // Player level (Beginner, Intermediate, Amateur, Expert)
    var playerStatus: String // Player status (Just for fun, Trainer, Competitor/Professional)
    var friends: [Friend] // List of friends
    var friendRequests: FriendRequests // Friend request details (incoming and outgoing)
}
extension AccountEntity {
    func toAccount() -> Account {
        return Account(
            id: self.id ?? UUID(),
            userName: self.userName ?? "",
            profilePictureURL: self.profilePictureURL,
            playerLevel: self.playerLevel ?? "",
            playerStatus: self.playerStatus ?? "",
            friends: (self.friends as? Set<FriendEntity>)?.map { $0.toFriend() } ?? [],
            friendRequests: self.friendRequests?.toFriendRequests() ?? FriendRequests(incoming: [], outgoing: [])
        )
    }
    
    func update(from account: Account, context: NSManagedObjectContext) {
        // Update basic attributes
        self.id = account.id
        self.userName = account.userName
        self.profilePictureURL = account.profilePictureURL
        self.playerLevel = account.playerLevel
        self.playerStatus = account.playerStatus
        
        // Update friends using mutableSetValue(forKey:)
        let friendsSet = self.mutableSetValue(forKey: "friends")
        friendsSet.removeAllObjects() // Clear existing friends if needed
        for friend in account.friends {
            let fetchRequest: NSFetchRequest<FriendEntity> = FriendEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", friend.id as CVarArg)
            
            let friendEntity: FriendEntity
            if let existingEntity = (try? context.fetch(fetchRequest))?.first {
                friendEntity = existingEntity
            } else {
                friendEntity = FriendEntity(context: context)
            }
            friendEntity.update(from: friend)
            friendsSet.add(friendEntity) // Add the friend to the relationship
        }
        
        // Update friendRequests
        if let existingFriendRequestsEntity = self.friendRequests {
            existingFriendRequestsEntity.update(from: account.friendRequests, context: context)
        } else {
            let newFriendRequestsEntity = FriendRequestsEntity(context: context)
            newFriendRequestsEntity.update(from: account.friendRequests, context: context)
            self.friendRequests = newFriendRequestsEntity
        }
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Failed to save AccountEntity: \(error.localizedDescription)")
        }
    }
}
//MARK: - Friend Models:
struct Friend: Identifiable, Codable, Hashable {
    let id: UUID // Unique ID of the friend
    let userName: String // Friend's username
    let profilePictureURL: String? // Optional profile picture
    let playerLevel: String // Friend's player level
}
extension FriendEntity {
    func toFriend() -> Friend {
        return Friend(
            id: self.id ?? UUID(),
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


// Represents friend request data
struct FriendRequests: Codable, Hashable {
    var incoming: [String] // List of usernames who sent requests
    var outgoing: [String] // List of usernames to whom requests were sent
}
extension FriendRequestsEntity {
    func toFriendRequests() -> FriendRequests {
        return FriendRequests(
            incoming: self.incoming as? [String] ?? [],
            outgoing: self.outgoing as? [String] ?? []
        )
    }

    func update(from friendRequests: FriendRequests, context: NSManagedObjectContext) {
        // Update incoming friend requests
        let incomingEntities = friendRequests.incoming.map { username in
            let fetchRequest: NSFetchRequest<FriendEntity> = FriendEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userName == %@", username)

            let friendEntity: FriendEntity
            if let existingEntity = (try? context.fetch(fetchRequest))?.first {
                friendEntity = existingEntity
            } else {
                friendEntity = FriendEntity(context: context)
                friendEntity.userName = username
            }
            return friendEntity
        }

        // Update outgoing friend requests
        let outgoingEntities = friendRequests.outgoing.map { username in
            let fetchRequest: NSFetchRequest<FriendEntity> = FriendEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "userName == %@", username)

            let friendEntity: FriendEntity
            if let existingEntity = (try? context.fetch(fetchRequest))?.first {
                friendEntity = existingEntity
            } else {
                friendEntity = FriendEntity(context: context)
                friendEntity.userName = username
            }
            return friendEntity
        }

        // Assign incoming and outgoing requests
        self.incoming = NSSet(array: incomingEntities)
        self.outgoing = NSSet(array: outgoingEntities)
    }
}
