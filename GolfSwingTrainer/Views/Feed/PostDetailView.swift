//
//  PostDetailView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var feedViewModel: FeedViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Profile Picture and Name
            HStack {
                if let profilePictureURL = post.profilePictureURL, !profilePictureURL.isEmpty {
                    AsyncImage(url: URL(string: profilePictureURL)) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color(.systemGray3))
                            .frame(width: 70, height: 70)
                    }
                }

                Text(post.userName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // Post Text
            Text(post.text)
                .font(.body)

            // Swing Duration
            if let duration = post.duration {
                Text("Swing Duration: \(duration)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Timestamp
            Text(post.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()

            // Delete Button
            Button(action: {
                Task {
                    await feedViewModel.deletePost(post)
                    dismiss()
                }
            }) {
                Text("Delete Post")
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Post Details")
    }
}

#Preview {
    PostDetailView(post: Post.MOCK_POST)
}
