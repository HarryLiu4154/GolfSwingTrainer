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
    let persistenceController = PersistenceController.shared
    @StateObject var viewModel = AuthViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView().environmentObject(viewModel).environment(\.managedObjectContext, persistenceController.container.viewContext)
                
            }
        }
    }
}
