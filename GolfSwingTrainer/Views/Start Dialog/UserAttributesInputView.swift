//
//  UserAttributesInputView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-05.
//

import SwiftUI

struct UserAttributesInputView: View {
    @State private var height: Double = 170 // Default in cm
    @State private var weight: Double = 70 // Default in kg
    @State private var age: Int = 30
    @State private var gender: String = "Male"
    @State private var dominantHand: String = "Right"
    
    private let genders = ["Male", "Female", "Non-Binary" ,"Other"]
    private let dominantHands = ["Right", "Left"]
    var body: some View {
        NavigationStack{
            ScrollView {
                Text("Your Physical Attributes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                VStack(alignment: .leading, spacing: 20) {
                    Section(String(localized: "Height")+String(localized: "(cm)")){
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "ruler")
                                Slider(value: $height, in: 120...220, step: 1)
                                    .accentColor(.green)
                                Text("\(Int(height)) cm")
                                    .foregroundColor(.secondary)
                            }
                        }.padding(.horizontal)
                    
                        
                    }.font(.headline).fontWeight(.semibold)
                    
                    
                    Section(String(localized: "Weight")+String(localized: "(kg)")){
                        // Weight Picker
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "scalemass")
                                Slider(value: $weight, in: 40...150, step: 1)
                                    .accentColor(.blue)
                                Text("\(Int(weight)) kg")
                                    .foregroundColor(.secondary)
                            }
                        }.padding(.horizontal)
                    }.font(.headline).fontWeight(.semibold)
                    
                    
                    // Age Picker
                    VStack(alignment: .leading) {
                        Text("Age")
                            .font(.headline)
                        Picker("Your age", selection: $age) {
                            ForEach(10...100, id: \.self){ age in
                                Text("\(age)")
                            }
                            
                        }.pickerStyle(.inline)
                            .padding(.horizontal)
                    }
                    
                    // Gender Picker
                    VStack(alignment: .leading) {
                        Text("Gender")
                            .font(.headline)
                        Picker("Select Gender", selection: $gender) {
                            ForEach(genders, id: \.self) { gender in
                                Text(gender)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    // Dominant Hand Picker
                    VStack(alignment: .leading) {
                        Text("Dominant Hand")
                            .font(.headline)
                        Picker("Select Dominant Hand", selection: $dominantHand) {
                            ForEach(dominantHands, id: \.self) { hand in
                                Text(hand)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    
                    // Submit Button
                    Button(action: submit) {
                        Text("Save Attributes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
        }
    }
    private func submit() {
            print("User Attributes Saved")
            // Here you would save to a model or submit to a server
        }
}


#Preview {
    UserAttributesInputView()
}
