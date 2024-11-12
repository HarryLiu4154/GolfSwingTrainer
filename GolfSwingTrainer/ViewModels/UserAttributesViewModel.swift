//
//  UserAttributesViewModel.swift
//  GolfSwingTrainer
//
//  Created by David on 2024-11-12.
//
import Foundation
import CoreData
import SwiftUI

class UserAttributesViewModel: ObservableObject {
    @Published var height: Int = 170
    @Published var weight: Int = 70
    @Published var birthDate: Date = Date.now
    @Published var gender: String = "Other"
    @Published var dominantHand: String = "Right"
    @Published var preferredMeasurement: String = "Metric"
    
    @Published var heights: ClosedRange<Int> = 120...220
    @Published var weights: ClosedRange<Int> = 40...150
    @Published var genders: [String] = ["Male", "Female", "Non-Binary" ,"Other"]
    @Published var dominantHands: [String] = ["Right", "Left"]
    @Published var preferredMeasurements: [String] = ["Imperial","Metric"]
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
           self.context = context
       }
    
    func saveUser(fullname: String, email: String) {
        let userEntity = UserEntity(context: context)
        userEntity.id = UUID()
        userEntity.fullName = fullname
        userEntity.email = email
        userEntity.height = Int16(height)
        userEntity.weight = Int16(weight)
        userEntity.birthDate = birthDate
        userEntity.gender = gender
        userEntity.dominantHand = dominantHand
        userEntity.preferredMeasurment = preferredMeasurement
        
        do {
            try context.save()
            print("User data saved successfully!")
        } catch {
            print("Error saving user data: \(error.localizedDescription)")
        }
    }
}
