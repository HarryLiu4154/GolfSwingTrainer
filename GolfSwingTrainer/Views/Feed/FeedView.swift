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

    var body: some View {
        NavigationStack {
            if let user = userDataViewModel.user, user.account != nil {
                // User has an account
                VStack {
                    if feedViewModel.posts.isEmpty {
                        Text("No posts available. Create the first one!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(feedViewModel.posts) { post in
                            NavigationLink(destination: PostDetailView(post: post).environmentObject(feedViewModel)) {
                                HStack(alignment: .top, spacing: 12) {
                                    // Profile Picture
                                    if let profilePictureURL = post.profilePictureURL, !profilePictureURL.isEmpty {
                                        AsyncImage(url: URL(string: profilePictureURL)) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            Circle()
                                                .fill(Color(.systemGray3))
                                                .frame(width: 50, height: 50)
                                        }
                                    } else {
                                        Circle()
                                            .fill(Color(.systemGray3))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text(post.userName.prefix(1))
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            )
                                    }

                                    // Post Content
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(post.userName)
                                            .font(.headline)

                                        Text(post.text)
                                            .font(.body)

                                        if let duration = post.duration {
                                            Text("Swing Duration: \(duration)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }

                                        Text(post.timestamp, style: .relative)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    NavigationLink(destination: CreatePostView().environmentObject(feedViewModel)
                                        .environmentObject(swingSessionViewModel)
                                        .environmentObject(userDataViewModel)){
                                        Text("Create Post")
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                }
                .navigationTitle("Feed")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
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
