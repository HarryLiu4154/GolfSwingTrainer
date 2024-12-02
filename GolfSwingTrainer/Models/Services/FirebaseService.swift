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
import SwiftUICore
import FirebaseStorage
import UIKit

class FirebaseService {
    private lazy var db = Firestore.firestore()
    private lazy var storage = Storage.storage()

    //MARK: - User Services

    func fetchUser(uid: String) async throws -> User? {
        let document = try await db.collection("users").document(uid).getDocument()
        return try document.data(as: User.self)
    }

    func saveUser(_ user: User) async throws {
        try await db.collection("users").document(user.uid).setData(Firestore.Encoder().encode(user))
    }

    func deleteUser(uid: String) async throws {
        try await db.collection("users").document(uid).delete()
    }
    

}
//MARK: - Swing Session Services
extension FirebaseService {
    func fetchAllSwingSessions(forUser userUID: String) async throws -> [SwingSession] {
        let querySnapshot = try await db.collection("swingSessions")
            .whereField("userUID", isEqualTo: userUID)
            .getDocuments()
        return querySnapshot.documents.compactMap { try? $0.data(as: SwingSession.self) }
    }

    func saveSwingSession(_ session: SwingSession, userUID: String) async throws {
        let docRef = db.collection("swingSessions").document(session.firebaseUID ?? UUID().uuidString)
        var updatedSession = session
        updatedSession.firebaseUID = docRef.documentID
        updatedSession.userUID = userUID 
        
        print("Saving session to Firestore: \(updatedSession)")
        
        try docRef.setData(from: updatedSession) { error in
            if let error = error {
                print("Error saving session to Firestore: \(error.localizedDescription)")
            } else {
                print("Session successfully saved with ID: \(docRef.documentID)")
            }
        }
    }

    func deleteSwingSession(uid: String) async throws {
        try await db.collection("swingSessions").document(uid).delete()
    }
}
//MARK: - Account services
extension FirebaseService {
    func uploadProfileImage(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])
        }
        
        // Generate a unique file path
        let imageId = UUID().uuidString
        let filePath = "profileImages/\(imageId).jpeg"
        let storageRef = Storage.storage().reference(withPath: filePath)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload image with async/await
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        // Retrieve the download URL
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
}
//MARK: - Friends services
extension FirebaseService {
    // Fetch an account by username
    func fetchAccountByUsername(username: String) async throws -> Account? {
        let querySnapshot = try await db.collection("users")
            .whereField("account.userName", isEqualTo: username)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else { return nil }
        let data = document.data()
        guard let accountData = data["account"] as? [String: Any] else { return nil }
        
        return Account(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            userName: accountData["userName"] as? String ?? "",
            profilePictureURL: accountData["profilePictureURL"] as? String,
            playerLevel: accountData["playerLevel"] as? String ?? "",
            playerStatus: accountData["playerStatus"] as? String ?? "",
            friends: accountData["friends"] as? [String] ?? [],
            friendRequests: accountData["friendRequests"] as? [String] ?? []
        )
    }


    // Add a friend to the current account
    func addFriend(currentUserId: String, friendUserId: String) async throws {
        let batch = db.batch()
        
        let currentUserRef = db.collection("users").document(currentUserId)
        let friendUserRef = db.collection("users").document(friendUserId)
        
        // Update current user's friend list
        batch.updateData(["account.friends": FieldValue.arrayUnion([friendUserId])], forDocument: currentUserRef)
        
        // Update friend's friend list
        batch.updateData(["account.friends": FieldValue.arrayUnion([currentUserId])], forDocument: friendUserRef)
        
        try await batch.commit()
    }


    // Send a friend request
    func sendFriendRequest(to userId: String, from currentUserId: String) async throws {
        let userRef = db.collection("users").document(userId)
        try await userRef.updateData(["account.friendRequests": FieldValue.arrayUnion([currentUserId])])
    }


    // Accept a friend request
    func acceptFriendRequest(currentUserId: String, from friendUserId: String) async throws {
        let batch = db.batch()
        
        let currentUserRef = db.collection("users").document(currentUserId)
        let friendUserRef = db.collection("users").document(friendUserId)
        
        // Remove the friend request and add the friend
        batch.updateData([
            "account.friendRequests": FieldValue.arrayRemove([friendUserId]),
            "account.friends": FieldValue.arrayUnion([friendUserId])
        ], forDocument: currentUserRef)
        
        // Add the current user as a friend in the other user's account
        batch.updateData([
            "account.friends": FieldValue.arrayUnion([currentUserId])
        ], forDocument: friendUserRef)
        
        try await batch.commit()
    }


    // Decline a friend request
    func declineFriendRequest(currentAccountId: String, from userId: String) async throws {
        let currentAccountRef = db.collection("accounts").document(currentAccountId)
        try await currentAccountRef.updateData(["friendRequests": FieldValue.arrayRemove([userId])])
    }

    // Remove a friend
    func removeFriend(currentUserId: String, friendUserId: String) async throws {
        let batch = db.batch()
        
        let currentUserRef = db.collection("users").document(currentUserId)
        let friendUserRef = db.collection("users").document(friendUserId)
        
        // Remove from both friend lists
        batch.updateData(["account.friends": FieldValue.arrayRemove([friendUserId])], forDocument: currentUserRef)
        batch.updateData(["account.friends": FieldValue.arrayRemove([currentUserId])], forDocument: friendUserRef)
        
        try await batch.commit()
    }
}
