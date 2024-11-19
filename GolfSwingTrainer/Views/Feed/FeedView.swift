//
//  FeedView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    @State var test: String = ""
    var body: some View {
        NavigationStack {
            VStack{
                List(viewModel.posts) { post in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(post.text)
                            .font(.body)
                        Text(post.timestamp, style: .time) // Shows the timestamp
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    TextField("Enter Post text",text: $test)
                        .padding(.vertical, 5)
                    Button(action: {
                        viewModel.addPost(text: test)
                    }, label: {})
                }
                .navigationTitle("Feed")
                .refreshable {
                    viewModel.fetchPosts() // Allow manual refresh
                }
            }.navigationTitle("Feed")
        }
    }
}

#Preview {
    FeedView().environmentObject(FeedViewModel())
}
