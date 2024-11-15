//
//  HomeView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-14.
//

import SwiftUI
/*using this temporary home screen until team makes the refined one*/
struct HomeView: View {
    var body: some View {
        NavigationStack{
            VStack{
                TabView{
                    UserProfileView().tabItem{
                        Label("Profile", systemImage: "person.fill")
                    }
                    SettingsView().tabItem{
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
        }.navigationTitle("Home")
    }
}

#Preview {
    HomeView()
}
