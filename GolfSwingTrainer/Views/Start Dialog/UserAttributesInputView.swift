//
//  UserAttributesInputView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-05.
//

import SwiftUI
import Foundation
import CoreData


struct UserAttributesInputView: View {
    //TODO: Impove seperation of concerns (UI + Logic)
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @Environment(\.dismiss) private var dismiss

    // Local state for input fields
    @State private var preferredMeasurement: String = "Metric"
    @State private var height: Int = 170
    @State private var weight: Int = 70
    @State private var birthDate: Date = Date()
    @State private var gender: String = "Male"
    @State private var dominantHand: String = "Right"
    @State private var isSaving = false

    // Dropdown/picker options
    private let measurements = ["Metric", "Imperial"]
    private let genders = ["Male", "Female", "Other"]
    private let dominantHands = ["Right", "Left"]
    private let heights = Array(120...250) // Heights in cm
    private let weights = Array(30...200) // Weights in kg

    var body: some View {
        
        NavigationStack {
            Form {
                // Description
                Section(header: Text("Why do we need this?")) {
                    Text("Providing accurate information helps us customize your experience and optimize training recommendations.")
                        .font(.subheadline)
                        .fontWeight(.thin)
                }

                // Input form
                Section(header: Text("Enter your physical attributes")) {
                    // Preferred Measurement
                    Picker("Measurements", selection: $preferredMeasurement) {
                        ForEach(measurements, id: \.self) { measurement in
                            Text(measurement)
                        }
                    }.pickerStyle(.segmented)

                    // Height
                    Picker("Height (cm)", selection: $height) {
                        ForEach(heights, id: \.self) { value in
                            Text("\(value) cm").tag(value)
                        }
                    }

                    // Weight
                    Picker("Weight (kg)", selection: $weight) {
                        ForEach(weights, id: \.self) { value in
                            Text("\(value) kg").tag(value)
                        }
                    }

                    // Birth Date
                    DatePicker("Birthday", selection: $birthDate, in: ...Date.now, displayedComponents: .date)

                    // Gender Picker
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }

                    // Dominant Hand Picker
                    Picker("Dominant Hand", selection: $dominantHand) {
                        ForEach(dominantHands, id: \.self) { hand in
                            Text(hand)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                // Save Button
                Button(action: saveUserAttributes) {
                    HStack {
                        Spacer()
                        Text(isSaving ? "Saving..." : "Continue")
                        if !isSaving {
                            Image(systemName: "arrow.right")
                        }
                        Spacer()
                    }
                }
                .disabled(isSaving)
            }
            .navigationTitle("Your Physical Attributes")
        }
        .onAppear(perform: populateFields) // Pre-fill fields if user data exists
    }

    // MARK: - Logic

    private func saveUserAttributes() {
        isSaving = true

        Task {
            await userDataViewModel.updateUserAttributes(
                preferredMeasurement: preferredMeasurement,
                height: height,
                weight: weight,
                birthDate: birthDate,
                gender: gender,
                dominantHand: dominantHand
            )
            isSaving = false

            // Mark user setup as complete and dismiss
            authViewModel.isUserSetupComplete = true
            dismiss()
            
        }
    }

    private func populateFields() {
        let attributes = userDataViewModel.getUserAttributes()
        preferredMeasurement = attributes.preferredMeasurement
        height = attributes.height
        weight = attributes.weight
        birthDate = attributes.birthDate
        gender = attributes.gender
        dominantHand = attributes.dominantHand
    }
}
