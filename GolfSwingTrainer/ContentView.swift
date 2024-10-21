//
//  ContentView.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI

struct ContentView: View {
    
    @State var index = 0
    
    init () {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        VStack {
            switch index {
                case 0:
                    HomeView()
                case 1:
                    TrackerView()
                case 2:
                    FriendsView()
                case 3:
                    SettingsView()
                default:
                    HomeView()
            }
            
            Spacer()
            
            CustomBottomNavigation(index: self.$index)
        }
        .background(Color.white.edgesIgnoringSafeArea(.top))
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    ContentView()
}
