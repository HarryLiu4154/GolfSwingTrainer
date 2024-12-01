//
//  HomeView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-14.
//

import SwiftUI
/*using this temporary home screen until team makes the refined one*/
struct HomeView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
    var body: some View {
        NavigationStack{
            
            VStack{
                //WeatherComponentView()
                TabView{
                    /*ProgressView().tabItem{
                        Label(String(localized: "Progress"), systemImage: "chart.bar.xaxis.ascending")
                    }*/
                    UserProfileView().tabItem{
                        Label(String(localized: "Profile"), systemImage: "person.fill")
                    }
                    SettingsView().environmentObject(swingSessionViewModel).tabItem{
                        Label(String(localized: "Settings"), systemImage: "gear")
                    }
                    FeedView().tabItem{
                        Label("Feed", systemImage: "paperplane.circle")
                    }
                }
            }
        }.navigationTitle("Home")
    }
}

#Preview {
    let coreDataService = CoreDataService()
    let firebaseService = FirebaseService()
    let userDataViewModel = UserDataViewModel(
        coreDataService: coreDataService,
        firebaseService: firebaseService
    )
    HomeView().environmentObject(userDataViewModel)
}
