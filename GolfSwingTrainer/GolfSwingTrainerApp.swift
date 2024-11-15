//
//  GolfSwingTrainerApp.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI
import WatchConnectivity

@main
struct GolfSwingTrainerApp: App {
    
    var sessionDelegate = WatchSessionDelegate()
    
    var body: some Scene {
        WindowGroup {
//            NavigationStack{
//                ProgressView()
//            }
            ContentView()
                .onAppear {
                    if (WCSession.isSupported()) {
                        let session = WCSession.default
                        session.delegate = sessionDelegate
                        session.activate()
                    }
                }
        }
    }
}
