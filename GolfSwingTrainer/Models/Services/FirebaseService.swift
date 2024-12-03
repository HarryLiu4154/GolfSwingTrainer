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
    private lazy var firestore = Firestore.firestore()
    private lazy var storage = Storage.storage()

    //MARK: - User Services

    func fetchUser(uid: String) async throws -> User? {
        let document = try await firestore.collection("users").document(uid).getDocument()
        return try document.data(as: User.self)
    }

    func saveUser(_ user: User) async throws {
        try await firestore.collection("users").document(user.uid).setData(Firestore.Encoder().encode(user))
    }

    func deleteUser(uid: String) async throws {
        try await firestore.collection("users").document(uid).delete()
    }
    

}
//MARK: - Swing Session Services
extension FirebaseService {
    ///
    func fetchAllSwingSessions(forUser userUID: String) async throws -> [SwingSession] {
        let querySnapshot = try await firestore.collection("swingSessions")
            .whereField("userUID", isEqualTo: userUID)
            .getDocuments()
        return querySnapshot.documents.compactMap { try? $0.data(as: SwingSession.self) }
    }

    ///
    func saveSwingSession(_ session: SwingSession, userUID: String) async throws {
        let docRef = firestore.collection("swingSessions").document(session.firebaseUID ?? UUID().uuidString)
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
        try await firestore.collection("swingSessions").document(uid).delete()
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
// MARK: - Friend Services
extension FirebaseService {
    func sendFriendRequest(from senderUserName: String, to recipientUserName: String) async throws {
        let recipientRef = firestore.collection("accounts").document(recipientUserName)
        let senderRef = firestore.collection("accounts").document(senderUserName)
        
        try await firestore.runTransaction { transaction, errorPointer in
            do {
                let recipientSnapshot = try transaction.getDocument(recipientRef)
                let senderSnapshot = try transaction.getDocument(senderRef)
                
                guard var recipientData = recipientSnapshot.data(),
                      var senderData = senderSnapshot.data() else {
                    throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid account data"])
                }
                
                // Update incoming requests for recipient
                var incomingRequests = recipientData["friendRequests.incoming"] as? [String] ?? []
                if !incomingRequests.contains(senderUserName) {
                    incomingRequests.append(senderUserName)
                    transaction.updateData(["friendRequests.incoming": incomingRequests], forDocument: recipientRef)
                }
                
                // Update outgoing requests for sender
                var outgoingRequests = senderData["friendRequests.outgoing"] as? [String] ?? []
                if !outgoingRequests.contains(recipientUserName) {
                    outgoingRequests.append(recipientUserName)
                    transaction.updateData(["friendRequests.outgoing": outgoingRequests], forDocument: senderRef)
                }
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }

    func acceptFriendRequest(recipientUserName: String, senderUserName: String) async throws {
        let recipientRef = firestore.collection("accounts").document(recipientUserName)
        let senderRef = firestore.collection("accounts").document(senderUserName)
        
        try await firestore.runTransaction { transaction, errorPointer in
            do {
                let recipientSnapshot = try transaction.getDocument(recipientRef)
                let senderSnapshot = try transaction.getDocument(senderRef)
                
                guard var recipientData = recipientSnapshot.data(),
                      var senderData = senderSnapshot.data() else {
                    throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid account data"])
                }
                
                // Add to friends array
                var recipientFriends = recipientData["friends"] as? [String] ?? []
                if !recipientFriends.contains(senderUserName) {
                    recipientFriends.append(senderUserName)
                    transaction.updateData(["friends": recipientFriends], forDocument: recipientRef)
                }
                
                var senderFriends = senderData["friends"] as? [String] ?? []
                if !senderFriends.contains(recipientUserName) {
                    senderFriends.append(recipientUserName)
                    transaction.updateData(["friends": senderFriends], forDocument: senderRef)
                }
                
                // Remove from friend requests
                var incomingRequests = recipientData["friendRequests.incoming"] as? [String] ?? []
                incomingRequests.removeAll(where: { $0 == senderUserName })
                transaction.updateData(["friendRequests.incoming": incomingRequests], forDocument: recipientRef)
                
                var outgoingRequests = senderData["friendRequests.outgoing"] as? [String] ?? []
                outgoingRequests.removeAll(where: { $0 == recipientUserName })
                transaction.updateData(["friendRequests.outgoing": outgoingRequests], forDocument: senderRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }

    func declineFriendRequest(recipientUserName: String, senderUserName: String) async throws {
        let recipientRef = firestore.collection("accounts").document(recipientUserName)
        let senderRef = firestore.collection("accounts").document(senderUserName)
        
        try await firestore.runTransaction { transaction, errorPointer in
            do {
                let recipientSnapshot = try transaction.getDocument(recipientRef)
                let senderSnapshot = try transaction.getDocument(senderRef)
                
                guard var recipientData = recipientSnapshot.data(),
                      var senderData = senderSnapshot.data() else {
                    throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid account data"])
                }
                
                // Remove from friend requests
                var incomingRequests = recipientData["friendRequests.incoming"] as? [String] ?? []
                incomingRequests.removeAll(where: { $0 == senderUserName })
                transaction.updateData(["friendRequests.incoming": incomingRequests], forDocument: recipientRef)
                
                var outgoingRequests = senderData["friendRequests.outgoing"] as? [String] ?? []
                outgoingRequests.removeAll(where: { $0 == recipientUserName })
                transaction.updateData(["friendRequests.outgoing": outgoingRequests], forDocument: senderRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }
}

