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
//MARK: - Account
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
