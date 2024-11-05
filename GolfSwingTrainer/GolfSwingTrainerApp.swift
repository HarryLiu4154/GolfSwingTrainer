//
//  GolfSwingTrainerApp.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

/* https://firebase.google.com/docs/ios/setup?_gl=1*djdlvs*_up*MQ..*_ga*MTgxNjM5NDE3Ny4xNzI4MDA0Njkw*_ga_CW55HF8NVT*MTcyODAwNDY5MS4xLjAuMTcyODAwNDY5MS4wLjAuMA.. */
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct GolfSwingTrainerApp: App {
    @StateObject var appState = AppState() // Track login status
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                if appState.isLoggedIn {
                    ProgressView().environmentObject(appState) //TODO: Insert home screen here
                }else{
                    //LoginView(appState: appState).environmentObject(appState)
                    LoginView()
                }
                
            }
        }
    }
}
