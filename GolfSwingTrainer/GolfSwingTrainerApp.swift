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
import UserNotifications

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
        
        //Request Notif Permissions
        requestNotificationPermissions()
        
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
    @State private var isNotificationVisible = false
    @State private var notificationTitle = ""
    @State private var notificationMessage = ""
    var body: some View {
        ZStack{
            if authViewModel.userSession != nil {
                if authViewModel.isUserSetupComplete {
                    MainTabView() //Home Screen
                } else {
                    UserAttributesInputView() // Show setup view if not complete
                }
            } else {
                LoginView()
            }
            
            InAppNotificationView(
                            title: notificationTitle,
                            message: notificationMessage,
                            isVisible: $isNotificationVisible
                        )
            
        }.onReceive(NotificationCenter.default.publisher(for: Notification.Name("WindDirectionChanged"))) { notification in
            if let userInfo = notification.userInfo,
               let title = userInfo["title"] as? String,
               let message = userInfo["message"] as? String {
                print("In-app notification received: \(title) - \(message)")
                notificationTitle = title
                notificationMessage = message
                isNotificationVisible = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isNotificationVisible = false
                }
            } else {
                print("Notification data is missing or malformed.")
            }
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
    RootView()
        .environmentObject(authViewModel)
        .environmentObject(userDataViewModel)
}

//MARK: - Permissions

///Notifications
func requestNotificationPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if let error = error {
            print("Notification permission error: \(error)")
        } else if granted {
            print("Permission granted for notifications.")
        }
    }
}
