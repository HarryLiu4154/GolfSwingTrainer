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
    
    var body: some View {
        NavigationStack {
            if let user = userDataViewModel.user {
                VStack {
                    // Navigate to Friends Management
                    NavigationLink(destination: FriendsView()
                        .environmentObject(userDataViewModel)) {
                            Text("Manage Friends")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding([.leading, .trailing])
                        }
                    
                    Divider()
                    
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
                .navigationTitle("Feed")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: CreatePostView()
                            .environmentObject(feedViewModel)
                            .environmentObject(swingSessionViewModel)
                            .environmentObject(userDataViewModel)) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                            }
                    }
                }
                .refreshable {
                    feedViewModel.fetchPosts()
                    await userDataViewModel.loadUser()
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
