//
//  GolfSwingTrainerApp.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI
import Firebase
import Foundation

@main
struct GolfSwingTrainerApp: App {
    @AppStorage("darkModeEnabled") var darkModeEnabled: Bool = false
    let persistenceController = PersistenceController.shared

    @StateObject var userDataViewModel: UserDataViewModel
    @StateObject var authViewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        
        // Initialize `userDataViewModel` first
        let userDataViewModelInstance = UserDataViewModel(
            coreDataService: CoreDataService(),
            firebaseService: FirebaseService()
        )
        _userDataViewModel = StateObject(wrappedValue: userDataViewModelInstance)
        
        // Then initialize `authViewModel` with the `userDataViewModel`
        _authViewModel = StateObject(wrappedValue: AuthViewModel(userDataViewModel: userDataViewModelInstance))
    }

    var body: some Scene {
        
        WindowGroup {
            NavigationStack{
                RootView()
                    .environmentObject(authViewModel)
                    .environmentObject(userDataViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    
                
            }.preferredColorScheme(darkModeEnabled ? .dark : .light) // Apply dark mode globally
        }
    }
}

//MARK: - Root navigation
struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: UserDataViewModel
    var body: some View {
       
        if authViewModel.userSession != nil {
            if authViewModel.isUserSetupComplete {
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
    let coreDataService = CoreDataService() // Replace with mock/in-memory service if needed
    let firebaseService = FirebaseService() // Replace with a mock Firebase service
    let userDataViewModel = UserDataViewModel(
        coreDataService: coreDataService,
        firebaseService: firebaseService
    )
    let authViewModel = AuthViewModel(userDataViewModel: userDataViewModel)
    return RootView()
        .environmentObject(authViewModel)
        .environmentObject(userDataViewModel)
}
