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
}

//MARK: - User Services
extension FirebaseService{
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
    /// Fetch an Account by UID
    func fetchAccount(for uid: String) async throws -> Account? {
        // Query account in `accounts` collection using `ownerUid`
        let query = firestore.collection("accounts").whereField("ownerUid", isEqualTo: uid).limit(to: 1)
        let snapshot = try await query.getDocuments()
        guard let document = snapshot.documents.first else { return nil }
        return try document.data(as: Account.self)
    }

    /// Create or Update an Account
    func saveAccount(_ account: Account, forUser uid: String) async throws {
        guard !account.userName.isEmpty else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Account userName cannot be empty"])
        }
        
        // Save account to the `accounts` collection
        try await firestore.collection("accounts").document(account.userName).setData(Firestore.Encoder().encode(account))
        
        // Also embed account in the corresponding user document
        let userRef = firestore.collection("users").document(uid)
        let accountData = try Firestore.Encoder().encode(account)
        try await userRef.updateData(["firestoreAccount": accountData])
    }
    

    /// Delete an Account
    func deleteAccount(userName: String, forUser uid: String) async throws {
        // Remove from `accounts` collection
        try await firestore.collection("accounts").document(userName).delete()
        
        // Remove embedded account from the user document
        let userRef = firestore.collection("users").document(uid)
        try await userRef.updateData(["firestoreAccount": FieldValue.delete()])
    }

    ///Upload profile image to firebase STORAGE
    func uploadProfileImage(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])
        }
        let imageId = UUID().uuidString
        let filePath = "profileImages/\(imageId).jpeg"
        let storageRef = storage.reference(withPath: filePath)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        try await storageRef.putDataAsync(imageData, metadata: metadata)
        return try await storageRef.downloadURL().absoluteString
    }
}

// MARK: - Friend Services
extension FirebaseService {
    /// Checks if a username is available in the accounts collection.
    func isUserNameAvailable(_ userName: String) async throws -> Bool {
        let documentRef = firestore.collection("accounts").document(userName)
        
        // Fetch the document for the given username
        let document = try await documentRef.getDocument()
        
        // If the document does not exist, the username is available
        return !document.exists
    }
    
    ///
    func sendFriendRequest(from senderUid: String, to recipientUid: String) async throws {
        // Query the sender's account
        let senderQuery = firestore.collection("accounts").whereField("ownerUid", isEqualTo: senderUid).limit(to: 1)
        let recipientQuery = firestore.collection("accounts").whereField("ownerUid", isEqualTo: recipientUid).limit(to: 1)
        
        // Fetch documents for both sender and recipient
        let senderSnapshot = try await senderQuery.getDocuments()
        let recipientSnapshot = try await recipientQuery.getDocuments()
        
        guard let senderDocument = senderSnapshot.documents.first else {
            throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Sender account not found"])
        }
        guard let recipientDocument = recipientSnapshot.documents.first else {
            throw NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Recipient account not found"])
        }
        
        let senderRef = senderDocument.reference
        let recipientRef = recipientDocument.reference

        // Run transaction to update friend requests
        try await firestore.runTransaction { transaction, errorPointer in
            do {
                let senderData = try transaction.getDocument(senderRef).data()
                let recipientData = try transaction.getDocument(recipientRef).data()
                
                guard var senderData = senderData,
                      var recipientData = recipientData else {
                    throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid account data"])
                }

                // Update outgoing requests for sender
                var senderOutgoing = senderData["friendRequests.outgoing"] as? [String] ?? []
                if !senderOutgoing.contains(recipientUid) {
                    senderOutgoing.append(recipientUid)
                    transaction.updateData(["friendRequests.outgoing": senderOutgoing], forDocument: senderRef)
                }

                // Update incoming requests for recipient
                var recipientIncoming = recipientData["friendRequests.incoming"] as? [String] ?? []
                if !recipientIncoming.contains(senderUid) {
                    recipientIncoming.append(senderUid)
                    transaction.updateData(["friendRequests.incoming": recipientIncoming], forDocument: recipientRef)
                }
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }



    ///
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

                var recipientFriends = recipientData["friends"] as? [String] ?? []
                var senderFriends = senderData["friends"] as? [String] ?? []

                recipientFriends.append(senderUserName)
                senderFriends.append(recipientUserName)

                transaction.updateData(["friends": recipientFriends], forDocument: recipientRef)
                transaction.updateData(["friends": senderFriends], forDocument: senderRef)

                var recipientIncoming = recipientData["friendRequests.incoming"] as? [String] ?? []
                var senderOutgoing = senderData["friendRequests.outgoing"] as? [String] ?? []

                recipientIncoming.removeAll { $0 == senderUserName }
                senderOutgoing.removeAll { $0 == recipientUserName }

                transaction.updateData(["friendRequests.incoming": recipientIncoming], forDocument: recipientRef)
                transaction.updateData(["friendRequests.outgoing": senderOutgoing], forDocument: senderRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }

    ///
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

                var recipientIncoming = recipientData["friendRequests.incoming"] as? [String] ?? []
                var senderOutgoing = senderData["friendRequests.outgoing"] as? [String] ?? []

                recipientIncoming.removeAll { $0 == senderUserName }
                senderOutgoing.removeAll { $0 == recipientUserName }

                transaction.updateData(["friendRequests.incoming": recipientIncoming], forDocument: recipientRef)
                transaction.updateData(["friendRequests.outgoing": senderOutgoing], forDocument: senderRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }
}
