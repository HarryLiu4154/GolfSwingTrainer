//
//  SettingsView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-14.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var userDataViewModel: UserDataViewModel
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
                Section(header: Text(String(localized: "Your Information")), footer: Text(String(localized: "Edit your information"))){
                    NavigationLink("Your attributes") {
                        SettingsAttributesView()
                            .environmentObject(userDataViewModel) 
                    }
                    
                }
                Button{
                    authViewModel.signOut()
                }label: {
                    SettingRowComponentView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: Color.yellow)
                    
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
