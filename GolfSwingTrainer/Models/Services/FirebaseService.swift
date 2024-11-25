//
//  FirebaseService.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    private lazy var db = Firestore.firestore()

    // Fetch user from Firebase
    func fetchUser(uid: String) async throws -> User? {
        print("FirebaseService: Fetching user from Firestore path: users/\(uid)")
        let document = try await db.collection("users").document(uid).getDocument()
        return try document.data(as: User.self)
    }

    // Save user to Firebase
    func saveUser(_ user: User) async throws {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("FirebaseService: No authenticated user.")
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user."])
        }

        print("FirebaseService: Saving user to Firestore path: users/\(currentUserUID)")

        var encodedUser = try Firestore.Encoder().encode(user)
        // Update the document ID to match Firebase UID
        try await db.collection("users").document(currentUserUID).setData(encodedUser)
        print("FirebaseService: Successfully saved user.")
    }


    // Delete user from Firebase
    func deleteUser(uid: String) async throws {
        print("FirebaseService: Deleting user from Firestore path: users/\(uid)")
        try await db.collection("users").document(uid).delete()
        print("FirebaseService: Successfully deleted user.")
    }
}
