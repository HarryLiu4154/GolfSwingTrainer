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
    
    // Variables that the user chooses from
    @Published var heights: ClosedRange<Int> = 120...220
    @Published var weights: ClosedRange<Int> = 40...150
    @Published var genders: [String] = ["Male", "Female", "Non-Binary" ,"Other"]
    @Published var dominantHands: [String] = ["Right", "Left"]
    @Published var preferredMeasurements: [String] = ["Imperial","Metric"]
    
    @Published var showSaveConfirmation: Bool = false // State for showing confirmation
    
    private let context: NSManagedObjectContext
    private var userEntity: UserEntity? // Reference to Core Data object
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadUser() // Load user data when initialized
    }
    // Load user attributes from Core Data
    func loadUser() {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let user = results.first {
                self.userEntity = user
                self.height = Int(user.height)
                self.weight = Int(user.weight)
                self.birthDate = user.birthDate ?? Date.now
                self.gender = user.gender ?? "Other"
                self.dominantHand = user.dominantHand ?? "Right"
                self.preferredMeasurement = user.preferredMeasurment ?? "Metric"
            }
        } catch {
            print("Failed to load user: \(error.localizedDescription)")
        }
    }
    
    // Save updated attributes to Core Data
    func saveAttributes() {
        if userEntity == nil {
            // Create new user if none exists
            userEntity = UserEntity(context: context)
            userEntity?.id = UUID()
        }
        
        userEntity?.height = Int16(height)
        userEntity?.weight = Int16(weight)
        userEntity?.birthDate = birthDate
        userEntity?.gender = gender
        userEntity?.dominantHand = dominantHand
        userEntity?.preferredMeasurment = preferredMeasurement
        
        do {
            try context.save()
            print("User attributes saved successfully!")
            showSaveConfirmation = true // Trigger confirmation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showSaveConfirmation = false // Hide after 2 seconds
            }
        } catch {
            print("Failed to save user attributes: \(error.localizedDescription)")
        }
    }
}
