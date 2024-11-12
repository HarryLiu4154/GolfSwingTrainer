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
    @StateObject private var viewModel: UserAttributesViewModel
    @Environment(\.managedObjectContext) private var context
      
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: UserAttributesViewModel(context: context))
    }
     
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
                        Picker("Measurments", selection: $viewModel.preferredMeasurement) {
                            ForEach(viewModel.preferredMeasurements, id: \.self) { measurement in
                                Text(measurement)
                            }
                        }.pickerStyle(.segmented)
                    }
                    
                    
                    //Height
                    HStack {
                        Image(systemName: "ruler")
                        Picker(String(localized: "Height")+String(localized: " (cm)"), selection: $viewModel.height){
                            ForEach(viewModel.heights, id: \.self) { height in
                                Text("\(height)cm").tag(height) // Display each height option
                            }
                        }.pickerStyle(.automatic)
                    }.font(.headline).fontWeight(.semibold)

                    //Weight
                    HStack{
                        Image(systemName: "scalemass")
                        Picker(String(localized: "Weight")+String(localized: " (kg)"), selection: $viewModel.weight){
                            ForEach(viewModel.weights, id: \.self ){ value in
                                Text("\(value) kg").tag(value) // Display each height option
                            }
                        }
                    }.font(.headline).fontWeight(.semibold)
                    
                    //Age/Birthday
                    HStack{
                        Image(systemName: "birthday.cake")
                        Text(String(localized: "Birthday"))
                        DatePicker(selection: $viewModel.birthDate, in: ...Date.now, displayedComponents: .date){}
                    }.font(.headline).fontWeight(.semibold)
                    
                    // Gender Picker
                    HStack{
                        Image(systemName: "person.fill.questionmark")
                        Picker("Gender", selection: $viewModel.gender) {
                            ForEach(viewModel.genders, id: \.self) { gender in
                                Text(gender)
                            }
                        }
                        .pickerStyle(.automatic)
                        
                    }.font(.headline).fontWeight(.semibold)
                    
                    
                    // Dominant Hand Picker
                    HStack {
                        Image(systemName: "hand.wave")
                        Text(String(localized: "Dominant Hand"))
                        Picker("Select Dominant Hand", selection: $viewModel.dominantHand) {
                            ForEach(viewModel.dominantHands, id: \.self) { hand in
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
    let context = PersistenceController.preview.container.viewContext
    UserAttributesInputView(context: context)
}

