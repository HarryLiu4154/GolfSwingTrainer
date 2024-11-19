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
        listener = db.collection("posts") //collection name on the firestore
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

                    return Post(
                        id: document.documentID,
                        text: text,
                        timestamp: timestamp.dateValue()
                    )
                }
            }
    }
    
    func addPost(text: String) {
        let post = [
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ] as [String: Any]

        Firestore.firestore().collection("posts").addDocument(data: post) { error in
            if let error = error {
                print("Error adding post: \(error.localizedDescription)")
            } else {
                print("Post added successfully!")
            }
        }
    }

    deinit {
        // Stop listening to Firestore updates when the ViewModel is deallocated
        listener?.remove()
    }
}
