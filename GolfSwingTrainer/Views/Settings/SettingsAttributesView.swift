//
//  SettingsAttributesView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-15.
//

import SwiftUI
import Foundation
import CoreData


struct SettingsAttributesView: View {
    @StateObject private var viewModel: UserAttributesViewModel
        
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: UserAttributesViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Physical Attributes") {
                    Stepper(value: $viewModel.height, in: viewModel.heights, step: 1) {
                        Text("Height: \(viewModel.height) cm")
                    }
                    Stepper(value: $viewModel.weight, in: viewModel.weights, step: 1) {
                        Text("Weight: \(viewModel.weight) kg")
                    }
                    DatePicker("Birth Date", selection: $viewModel.birthDate, displayedComponents: .date)
                    Picker("Gender", selection: $viewModel.gender) {
                        ForEach(viewModel.genders, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Dominant Hand", selection: $viewModel.dominantHand) {
                        ForEach(viewModel.dominantHands, id: \.self) {
                            Text($0)
                        }
                    }
                    Picker("Preferred Measurement", selection: $viewModel.preferredMeasurement) {
                        ForEach(viewModel.preferredMeasurements, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .navigationTitle("Your Attributes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveAttributes()
                    }
                }
            }
        }
        // Show temporary confirmation
        if viewModel.showSaveConfirmation {
            VStack {
                Image(systemName: "checkmark.circle")
                
            }
            .transition(.opacity)
            .animation(.easeInOut, value: viewModel.showSaveConfirmation)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return SettingsAttributesView(context: context)
}
