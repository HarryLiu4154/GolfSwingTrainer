//
//  GolfSwingTrainerApp.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI
import Firebase

@main
struct GolfSwingTrainerApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView().environmentObject(viewModel)
                
            }
        }
    }
}
