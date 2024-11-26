//
//  CreatePostView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//

import SwiftUI
import Foundation

struct CreatePostView: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
        @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
        @Environment(\.dismiss) var dismiss

        @State private var postText: String = ""
        @State private var selectedSession: SwingSession? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Post Content")) {
                    TextField("Enter your post text", text: $postText)
                        .textFieldStyle(.roundedBorder)
                }
                
                Section(header: Text("Attach a Swing Session (Optional)")) {
                    Picker("Select Session", selection: $selectedSession) {
                        Text("None").tag(SwingSession?.none)
                        ForEach(swingSessionViewModel.sessions) { session in
                            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                .tag(session as SwingSession?)
                        }
                    }
                }
            }
            .navigationTitle("Create Post")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        let duration = selectedSession.map { "\($0.rotationData.count) sec" }
                        feedViewModel.addPost(text: postText, duration: duration)
                        dismiss() // Return to FeedView
                    }
                    .disabled(postText.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CreatePostView().environmentObject(FeedViewModel())
        .environmentObject(SwingSessionViewModel(
            coreDataService: CoreDataService(),
            firebaseService: FirebaseService(),
            userUID: User.MOCK_USER.uid
        ))
}