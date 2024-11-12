//
//  UserAttributesInputView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-05.
//

import SwiftUI

struct UserAttributesInputView: View {
    @State private var height: Int = 170 // Default in cm
    @State private var weight: Int = 70 // Default in kg
    @State private var birthDate = Date.now
    @State private var gender: String = "Other"
    @State private var dominantHand: String = "Right"
    @State private var preferredMeasurement: String = "Metric"
    private let heights = 120...220
    private let weights = 40...150
    private let genders = ["Male", "Female", "Non-Binary" ,"Other"]
    private let dominantHands = ["Right", "Left"]
    private let preferredMeasurements = ["Imperial","Metric"]
    var body: some View {
        NavigationStack{
            Form{
                //Decription
                Section(header: Text("Why do we need this?")){
                    Text("TODO: ").font(.subheadline).fontWeight(.thin)
                }
                
                //Input form
                Section(header: Text("Enter your physical attributes")){
                    
                    //Preferred Measurment
                    HStack(){
                        Picker("Measurments", selection: $preferredMeasurement) {
                            ForEach(preferredMeasurements, id: \.self) { measurement in
                                Text(measurement)
                            }
                        }.pickerStyle(.segmented)
                    }
                    
                    
                    //Height
                    HStack {
                        Image(systemName: "ruler")
                        Picker(String(localized: "Height")+String(localized: " (cm)"), selection: $height){
                            ForEach(heights, id: \.self) { height in
                                Text("\(height)cm").tag(height) // Display each height option
                            }
                        }.pickerStyle(.automatic)
                    }.font(.headline).fontWeight(.semibold)

                    //Weight
                    HStack{
                        Image(systemName: "scalemass")
                        Picker(String(localized: "Weight")+String(localized: " (kg)"), selection: $weight){
                            ForEach(weights, id: \.self ){ value in
                                Text("\(value) kg").tag(value) // Display each height option
                            }
                        }
                    }.font(.headline).fontWeight(.semibold)
                    
                    //Age/Birthday
                    HStack{
                        Image(systemName: "birthday.cake")
                        Text(String(localized: "Birthday"))
                        DatePicker(selection: $birthDate, in: ...Date.now, displayedComponents: .date){}
                    }.font(.headline).fontWeight(.semibold)
                    
                    // Gender Picker
                    HStack{
                        Image(systemName: "person.fill.questionmark")
                        Picker("Gender", selection: $gender) {
                            ForEach(genders, id: \.self) { gender in
                                Text(gender)
                            }
                        }
                        .pickerStyle(.automatic)
                        
                    }.font(.headline).fontWeight(.semibold)
                    
                    
                    // Dominant Hand Picker
                    HStack {
                        Image(systemName: "hand.wave")
                        Text(String(localized: "Dominant Hand"))
                        Picker("Select Dominant Hand", selection: $dominantHand) {
                            ForEach(dominantHands, id: \.self) { hand in
                                Text(hand)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }.font(.headline).fontWeight(.semibold)
                    
                }
                Button(action: {
                    //TODO:
                }, label: {
                    HStack(alignment: .lastTextBaseline){
                        
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                })
            }.navigationTitle("Your physical attributes")
            
        }
    }
}



#Preview {
    UserAttributesInputView()
}

