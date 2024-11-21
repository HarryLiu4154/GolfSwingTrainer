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
                    ProgressView().tabItem{
                        Label(String(localized: "Progress"), systemImage: "chart.bar.xaxis.ascending")
                    }
                    UserProfileView().tabItem{
                        Label(String(localized: "Profile"), systemImage: "person.fill")
                    }
                    SettingsView().tabItem{
                        Label(String(localized: "Settings"), systemImage: "gear")
                    }
                }
            }
        }.navigationTitle("Home")
    }
}

#Preview {
    HomeView()
}
