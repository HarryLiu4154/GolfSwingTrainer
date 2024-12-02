//
//  PostRowComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//

import SwiftUI

struct PostRowComponentView: View {
    let post: Post
    
    var body: some View {
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
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    PostRowComponentView(post: Post.MOCK_POST)
}
