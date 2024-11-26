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
                          let timestamp = data["timestamp"] as? Timestamp else { return nil }
                    let duration = data["duration"] as? String

                    return Post(
                        id: document.documentID,
                        text: text,
                        timestamp: timestamp.dateValue(),
                        duration: duration
                    )
                }
            }
    }

    func addPost(text: String, duration: String?) {
        let post: [String: Any] = [
            "text": text,
            "timestamp": FieldValue.serverTimestamp(),
            "duration": duration ?? ""
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
