//
//  User.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-04.
//

import Foundation
import CoreData

/// This user model represents the user progamatically. The "MOCKUSER" extension, represents a fake user to be tested in code
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
            weight: Int(self.weight)
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
        try? context.save() // Save context after updating
    }
}
extension User{
    //test user
    static var MOCK_USER = User(id: NSUUID() as UUID, uid:"",fullName: "Tiger Woods", email: "tigerwoods@tigerwoods.com", birthDate: Date(),dominantHand: "Right",gender: "Male", height: 170, preferredMeasurement: "Metric",weight: 100)
}
