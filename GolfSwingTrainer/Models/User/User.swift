//
//  User.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-04.
//

import Foundation
import CoreData

// MARK: - AccountModel
struct Account: Identifiable, Codable, Hashable {
    let id: UUID // Unique identifier for the account
    var userName: String // Unique username for the user
    var profilePictureURL: String? // Optional profile picture URL
    var playerLevel: String // Player level (Beginner, Intermediate, Amateur, Expert)
    var playerStatus: String // Player status (Just for fun, Trainer, Competitor/Professional)
    var friends: [String] // List of friend IDs
    var friendRequests: [String] // List of incoming friend request IDs
}
extension AccountEntity {
    func toAccount() -> Account {
        return Account(
            id: self.id ?? UUID(),
            userName: self.userName ?? "",
            profilePictureURL: self.profilePictureURL,
            playerLevel: self.playerLevel ?? "",
            playerStatus: self.playerStatus ?? "",
            friends: self.friends as? [String] ?? [],
            friendRequests: self.friendRequests as? [String] ?? []
        )
    }

    func update(from account: Account, context: NSManagedObjectContext) {
        self.id = account.id
        self.userName = account.userName
        self.profilePictureURL = account.profilePictureURL
        self.playerLevel = account.playerLevel
        self.playerStatus = account.playerStatus
        self.friends = account.friends as NSArray
        self.friendRequests = account.friendRequests as NSArray
        try? context.save()
    }
}
// MARK: - UserModel
struct User: Identifiable, Codable{
    let id: UUID // Core Data identifier
    let uid: String // Firebase identifier
    var fullName: String
    var email: String
    var birthDate: Date
    var dominantHand: String
    var gender: String
    var height: Int
    var preferredMeasurement: String
    var weight: Int
    var account: Account? //User may not have an account
    
    //returns users name as initals for later display (e.g. Tiger Woods -> TW)
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
//maps between UserEntity (Core Data object) and the User struct. This decouples the Core Data layer from the rest of the app.
extension UserEntity {
    // Convert Core Data object to a User struct
    func toUser() -> User {
        return User(
            id: self.id ?? UUID(),
            uid: self.uid ?? "",
            fullName: self.fullName ?? "",
            email: self.email ?? "",
            birthDate: self.birthDate ?? Date(),
            dominantHand: self.dominantHand ?? "",
            gender: self.gender ?? "",
            height: Int(self.height),
            preferredMeasurement: self.preferredMeasurement ?? "",
            weight: Int(self.weight),
            account: self.account?.toAccount()
        )
    }

    // Update Core Data object from a User struct
    func update(from user: User, context: NSManagedObjectContext) {
        self.id = user.id
        self.uid = user.uid
        self.fullName = user.fullName
        self.email = user.email
        self.birthDate = user.birthDate
        self.dominantHand = user.dominantHand
        self.gender = user.gender
        self.height = Int16(user.height)
        self.preferredMeasurement = user.preferredMeasurement
        self.weight = Int16(user.weight)
        if let account = user.account {
            if let accountEntity = self.account {
                accountEntity.update(from: account, context: context)
            } else {
                let newAccountEntity = AccountEntity(context: context)
                newAccountEntity.update(from: account, context: context)
                self.account = newAccountEntity
            }
        }
        try? context.save() // Save context after updating
    }
}

extension User{
    //test user
    static var MOCK_USER = User(
            id: UUID(),
            uid: "",
            fullName: "Tiger Woods",
            email: "tigerwoods@tigerwoods.com",
            birthDate: Date(),
            dominantHand: "Right",
            gender: "Male",
            height: 170,
            preferredMeasurement: "Metric",
            weight: 100,
            account: Account(
                id: UUID(),
                userName: "tigerwoods",
                profilePictureURL: "",
                playerLevel: "Expert",
                playerStatus: "Competitor/Professional",
                friends: ["",""],
                friendRequests: ["",""]
            )
        )
}
