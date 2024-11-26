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
