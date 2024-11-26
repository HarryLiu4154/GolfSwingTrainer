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
    var body: some View {
        NavigationStack {
            VStack {
                if feedViewModel.posts.isEmpty {
                    Text("No posts available. Create the first one!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(feedViewModel.posts) { post in
                        VStack(alignment: .leading, spacing: 5) {
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
                        .padding(.vertical, 5)
                    }
                }
                NavigationLink("Create Post") {
                    CreatePostView()
                        .environmentObject(feedViewModel)
                        .environmentObject(swingSessionViewModel)
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    
                }
            }
            .refreshable {
                feedViewModel.fetchPosts()
            }
        }
    }
}
#Preview {
    FeedView().environmentObject(FeedViewModel())
}
