//
//  SettingsAttributesView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-15.
//


import Foundation
import CoreData
import SwiftUI

struct SettingsAttributesView: View {
    //TODO: Impove seperation of concerns (UI + Logic)
    @EnvironmentObject var userDataViewModel: UserDataViewModel

    // Temporary local state for user attributes
    @State private var height: Int = 170
    @State private var weight: Int = 70
    @State private var birthDate: Date = Date()
    @State private var gender: String = "Male"
    @State private var dominantHand: String = "Right"
    @State private var preferredMeasurement: String = "Metric"
    @State private var showSaveConfirmation: Bool = false // Show save confirmation

    // Dropdown/picker options
    private let genders = ["Male", "Female", "Other"]
    private let dominantHands = ["Right", "Left"]
    private let preferredMeasurements = ["Metric", "Imperial"]
    private let heightRange = 120...250
    private let weightRange = 30...200

    var body: some View {
        NavigationStack {
            Form {
                Section("Physical Attributes") {
                    // Height
                    Stepper(value: $height, in: heightRange, step: 1) {
                        Text("Height: \(height) cm")
                    }

                    // Weight
                    Stepper(value: $weight, in: weightRange, step: 1) {
                        Text("Weight: \(weight) kg")
                    }

                    // Birth Date
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)

                    // Gender Picker
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) {
                            Text($0)
                        }
                    }

                    // Dominant Hand Picker
                    Picker("Dominant Hand", selection: $dominantHand) {
                        ForEach(dominantHands, id: \.self) {
                            Text($0)
                        }
                    }

                    // Preferred Measurement Picker
                    Picker("Preferred Measurement", selection: $preferredMeasurement) {
                        ForEach(preferredMeasurements, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .onAppear {
                loadAttributes()
            }
            .navigationTitle("Your Attributes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAttributes()
                    }
                }
            }
        }
    }

    // MARK: - Logic

    private func loadAttributes() {
        guard let user = userDataViewModel.user else { return }

        height = user.height
        weight = user.weight
        birthDate = user.birthDate
        gender = genders.contains(user.gender) ? user.gender : genders[0] // Default to first option if invalid
        dominantHand = dominantHands.contains(user.dominantHand) ? user.dominantHand : dominantHands[0]
        preferredMeasurement = preferredMeasurements.contains(user.preferredMeasurement) ? user.preferredMeasurement : preferredMeasurements[0]
    }

    private func saveAttributes() {
        // Save updated attributes via UserDataViewModel
        Task {
            await userDataViewModel.updateUserAttributes(
                preferredMeasurement: preferredMeasurement,
                height: height,
                weight: weight,
                birthDate: birthDate,
                gender: gender,
                dominantHand: dominantHand
            )
            
            // Show save confirmation
            DispatchQueue.main.async {
                showSaveConfirmation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSaveConfirmation = false
            }
        }
    }
}

#Preview {
    let coreDataService = CoreDataService()
    let firebaseService = FirebaseService()
    let userDataViewModel = UserDataViewModel(coreDataService: coreDataService, firebaseService: firebaseService)

    return SettingsAttributesView()
        .environmentObject(userDataViewModel)
}
