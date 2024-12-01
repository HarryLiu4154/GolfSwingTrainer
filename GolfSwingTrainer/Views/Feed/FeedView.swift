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
            VStack {
                if feedViewModel.posts.isEmpty {
                    Text("No posts available. Create the first one!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(feedViewModel.posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            HStack(alignment: .top, spacing: 10) {
                                // Profile Picture
                                if let url = post.profilePictureURL, let imageURL = URL(string: url) {
                                    AsyncImage(url: imageURL) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 50, height: 50)
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 50, height: 50)
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
                                    Text(post.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                NavigationLink("Create Post") {
                    CreatePostView()
                        .environmentObject(feedViewModel)
                        .environmentObject(swingSessionViewModel)
                        .environmentObject(userDataViewModel)
                }
            }
            .navigationTitle("Feed")
            .refreshable {
                feedViewModel.fetchPosts()
            }
        }
    }
}

#Preview {
    FeedView().environmentObject(FeedViewModel())
}
