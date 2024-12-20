//
//  SettingsView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-14.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @EnvironmentObject var motionDataViewModel: MotionDataViewModel
    @Environment(\.managedObjectContext) private var context // Access Core Data context from the environment

    var body: some View {
        NavigationStack{
            Form{
                Section(header: Text(String(localized: "Display")), footer: Text(String(localized: "Adjust your screen"))){
                    Toggle(isOn: $viewModel.darkModeEnabled,
                           label: {
                        Text(String(localized: "Dark Mode"))
                    })
                    
                }
                Section(header: Text(String(localized: "Your Account Information")), footer: Text(String(localized: "Edit & view your account information"))){
                    NavigationLink("Your Account") {
                        SettingsAccountView()
                            .environmentObject(userDataViewModel)
                    }
                }
                Section(header: Text(String(localized: "Your Personal Information")), footer: Text(String(localized: "Edit your information"))){
                    
                    NavigationLink("Your Attributes") {
                        SettingsAttributesView()
                            .environmentObject(userDataViewModel)
                    }
                    NavigationLink("Your Swings") {
                        SwingSessionListView()
                            .environmentObject(swingSessionViewModel)
                    }
                
                    
                }
                Section(header: Text(String(localized: "Developer Settings")), footer: Text(String(localized: "For Dev Eyes Only"))){
                    NavigationLink("Test Watch Sensor Ingestion"){
                        WatchMotionView().environmentObject(swingSessionViewModel)
                            .environmentObject(motionDataViewModel)
                    }
                    NavigationLink("ML Tests") {
                        CameraViewControllerWrapper()
                    }
                    
                    
                }
                
            }.navigationTitle("Settings")
                .preferredColorScheme(viewModel.darkModeEnabled ? .dark : .light) 
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    SettingsView().environment(\.managedObjectContext, context).environmentObject(AuthViewModel(userDataViewModel: UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService())))
}
