//
//  FeedViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-19.
//

import Foundation
import FirebaseFirestore

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = [] // Real-time feed of posts

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchPosts()
    }

    // Fetch posts in real-time
    func fetchPosts() {
        listener = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                self.posts = documents.compactMap { document in
                    let data = document.data()
                    guard let text = data["text"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let userName = data["userName"] as? String else { return nil }
                    let duration = data["duration"] as? String
                    let profilePictureURL = data["profilePictureURL"] as? String
                    
                    return Post(
                        id: document.documentID,
                        text: text,
                        timestamp: timestamp.dateValue(),
                        duration: duration,
                        userName: userName,
                        profilePictureURL: profilePictureURL
                    )
                }
            }
    }

    func addPost(text: String, duration: String?, userName: String, profilePictureURL: String?) {
        let post: [String: Any] = [
            "text": text,
            "timestamp": FieldValue.serverTimestamp(),
            "duration": duration ?? "",
            "userName": userName,
            "profilePictureURL": profilePictureURL ?? ""
        ]

        db.collection("posts").addDocument(data: post) { error in
            if let error = error {
                print("Error adding post: \(error.localizedDescription)")
            } else {
                print("Post added successfully!")
            }
        }
    }


    deinit {
        listener?.remove()
    }
}
