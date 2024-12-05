//
//  FeedView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @State private var friendUsername: String = "" // To input username for friend operations
    @State private var showFriendRequests = false // To toggle friend request management screen

    var body: some View {
        NavigationStack {
            if let user = userDataViewModel.user {
                VStack {
                    // Posts Section
                    if feedViewModel.posts.isEmpty {
                        Text("No posts available. Create the first one!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(feedViewModel.posts) { post in
                            NavigationLink(destination: PostDetailView(post: post).environmentObject(feedViewModel)) {
                                PostRowComponentView(post: post)
                            }
                        }
                    }
                }
                .toolbar {
                    
                }
                .navigationTitle("Feed")
                .refreshable {
                    feedViewModel.fetchPosts()
                    await userDataViewModel.loadUser()
                }
                .sheet(isPresented: $showFriendRequests) {
                    FriendRequestsView()
                        .environmentObject(userDataViewModel)
                }
            } else {
                // User does not have an account
                VStack(spacing: 20) {
                    Text("You need an account to access the feed.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink("Create Account") {
                        CreateAccountView()
                            .environmentObject(userDataViewModel)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .navigationTitle("Feed")
            }
        }
    }
}
#Preview {
    FeedView().environmentObject(FeedViewModel())
}
