//
//  GolfSwingTrainerApp.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI
import Firebase

class  test : ObservableObject
{
    
}
@main
struct GolfSwingTrainerApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    
    
    let persistenceController = PersistenceController.shared
    @StateObject var viewModel = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                RootView().environmentObject(viewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    //.environmentObject(t)
                
            }.preferredColorScheme(darkModeEnabled ? .dark : .light) // Apply dark mode globally
        }
    }
}

//MARK: - Root navigation
struct RootView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
            if viewModel.userSession != nil {
                if viewModel.isUserSetupComplete {
                    //TODO: Add home screen
                    HomeView()
                } else {
                    UserAttributesInputView() // Show setup view if not complete
                }

            } else {
                LoginView()
            }
        
    }
}
#Preview {
    RootView().environmentObject(AuthViewModel())
}
