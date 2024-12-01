//
//  PostDetailView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let url = post.profilePictureURL, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 100, height: 100)
                }
            }

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
            Spacer()
        }
        .padding()
        .navigationTitle("Post Details")
    }
}


#Preview {
    PostDetailView(post: Post.MOCK_POST)
}
