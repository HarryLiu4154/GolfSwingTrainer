//
//  GolfSwingTrainerApp.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseCore
import Foundation

@main
struct GolfSwingTrainerApp: App {
    @AppStorage("darkModeEnabled") var darkModeEnabled: Bool = false
    let persistenceController = PersistenceController.shared

    @StateObject var userDataViewModel: UserDataViewModel
    @StateObject var authViewModel: AuthViewModel
    @StateObject var swingSessionViewModel: SwingSessionViewModel
    @StateObject var feedViewModel: FeedViewModel
    
    init() {
        //Firebase configs
        FirebaseApp.configure()
        let storage = Storage.storage()
               print("Default Firebase Storage Bucket: \(storage.reference().bucket)")
        
        // Initialize `userDataViewModel` first
        let userDataViewModelInstance = UserDataViewModel(
            coreDataService: CoreDataService(),
            firebaseService: FirebaseService()
        )
        _userDataViewModel = StateObject(wrappedValue: userDataViewModelInstance)
        
        // Initialize `authViewModel` with the `userDataViewModel`
        let authViewModelInstance = AuthViewModel(userDataViewModel: userDataViewModelInstance)
        _authViewModel = StateObject(wrappedValue: authViewModelInstance)
        
        // Initialize `swingSessionViewModel` with the userUID from `AuthViewModel`
        let userUID = authViewModelInstance.userSession?.uid ?? "" // Ensure a default value
        _swingSessionViewModel = StateObject(wrappedValue: SwingSessionViewModel(
            coreDataService: userDataViewModelInstance.coreDataService,
            firebaseService: userDataViewModelInstance.firebaseService,
            userUID: userUID
        ))
        
        _feedViewModel = StateObject(wrappedValue: FeedViewModel())
    }

    var body: some Scene {
        
        WindowGroup {
            NavigationStack{
                RootView()
                    .environmentObject(authViewModel)
                    .environmentObject(userDataViewModel)
                    .environmentObject(swingSessionViewModel)
                    .environmentObject(feedViewModel)
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
                MainTabView() //Home Screen
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
