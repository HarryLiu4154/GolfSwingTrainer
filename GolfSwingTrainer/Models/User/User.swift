//
//  User.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-04.
//

import Foundation
import CoreData

struct User: Identifiable, Codable {
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
    var firestoreAccount: Account? // Optional Firestore account data
    
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
///maps between UserEntity (Core Data object) and the User struct. This decouples the Core Data layer from the rest of the app.
extension UserEntity {
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
            firestoreAccount: self.account?.toAccount()
        )
    }

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

        if let firestoreAccount = user.firestoreAccount {
            let accountEntity = AccountEntity(context: context)
            accountEntity.update(from: firestoreAccount, context: context)
            self.account = accountEntity
        }

        do {
            try context.save()
        } catch {
            print("Failed to save UserEntity: \(error.localizedDescription)")
        }
    }
}

extension User {
    // Test user
    static var MOCK_USER = User(
        id: UUID(),
        uid: "12345",
        fullName: "Tiger Woods",
        email: "tigerwoods@tigerwoods.com",
        birthDate: Date(),
        dominantHand: "Right",
        gender: "Male",
        height: 185,
        preferredMeasurement: "Metric",
        weight: 80,
        firestoreAccount: Account(
            id: UUID(),
            ownerUid: "FakeOwnerUuid",
            userName: "tigerwoods",
            profilePictureURL: "https://example.com/profile.jpg",
            playerLevel: "Expert",
            playerStatus: "Competitor/Professional",
            friends: [
                Friend(
                    id: "FakeFriendUuid1",
                    userName: "jacknicklaus",
                    profilePictureURL: "https://example.com/jack.jpg",
                    playerLevel: "Legendary"
                ),
                Friend(
                    id: "FakeFriendUuid2",
                    userName: "phil",
                    profilePictureURL: "https://example.com/phil.jpg",
                    playerLevel: "Intermediate"
                )
            ],
            friendRequests: FriendRequests(
                incoming: ["arnoldpalmer", "severiano"],
                outgoing: ["johnsmith", "benhogan"]
            )
        )
    )
}

