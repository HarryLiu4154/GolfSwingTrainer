//
//  MainTabView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//

import SwiftUI


struct MainTabView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel

    @State private var selectedTab: Tab = .home
    @State private var showMenu: Bool = false // Manage MenuView visibility

    var body: some View {
        let drag = DragGesture()
            .onEnded { value in
                if value.translation.width < -100 {
                    withAnimation {
                        showMenu = false
                    }
                }
            }

        return NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) { // Align MenuView to the left edge
                    // Main Content (TabView)
                    TabView(selection: $selectedTab) {
                        HomeView(showMenu: $showMenu)
                            .environmentObject(userDataViewModel)
                            .environmentObject(authViewModel)
                            .environmentObject(swingSessionViewModel)
                            .tabItem {
                                Label("Home", systemImage: selectedTab == .home ? "house.fill" : "house")
                            }
                            .tag(Tab.home)

                        FeedView()
                            .environmentObject(userDataViewModel)
                            .environmentObject(authViewModel)
                            .environmentObject(swingSessionViewModel)
                            .tabItem {
                                Label("Feed", systemImage: selectedTab == .feed ? "paperplane.circle.fill" : "paperplane.circle")
                            }
                            .tag(Tab.feed)

//                        ProgressView()
//                            .tabItem {
//                                Label("Progress", systemImage: selectedTab == .progress ? "chart.bar.fill" : "chart.bar")
//                            }
//                            .tag(Tab.progress)


                    }
                    .offset(x: showMenu ? geometry.size.width / 2 : 0) // Slide content when menu is open
                    .disabled(showMenu) // Disable TabView interaction when menu is open

                    // MenuView Overlay
                    if showMenu {
                        MenuView()
                            .environmentObject(userDataViewModel)
                            .environmentObject(swingSessionViewModel)
                            .environmentObject(authViewModel)
                            .frame(width: geometry.size.width / 2)
                            .offset(x: showMenu ? 0 : -geometry.size.width / 2) // Start off-screen
                            .animation(.easeInOut, value: showMenu) // Smooth animation
                    }
                }
            }
            .gesture(drag) // Allow drag to close menu
            //MARK: - Tab Controls
            .toolbar {
                // Menu Toggle Button (always on)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                }
                
                if selectedTab == Tab.feed{
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: CreatePostView()
                            .environmentObject(feedViewModel)
                            .environmentObject(swingSessionViewModel)
                            .environmentObject(userDataViewModel)) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing){
                        // Navigate to Friends Management
                        //TODO: Make button invalid if user != account
                        
                        NavigationLink(destination: FriendsView()
                            .environmentObject(userDataViewModel)) {
                                
                                Image(systemName: "person.badge.plus")
                                    .font(.title2)
                                
                                /*Text("Manage Friends")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding([.leading, .trailing])*/
                            }
                    }
                       
                }
            }
        }
    }
}

enum Tab: Hashable {
    case home
    case feed
    case progress
    //case profile
}
#Preview {
    MainTabView()
}
