//
//  SwingSessionViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//
import Foundation

@MainActor
class SwingSessionViewModel: ObservableObject {
    @Published var sessions: [SwingSession] = []
    private let coreDataService: CoreDataService
    private let firebaseService: FirebaseService
    private let userUID: String

    init(coreDataService: CoreDataService, firebaseService: FirebaseService, userUID: String) {
        self.coreDataService = coreDataService
        self.firebaseService = firebaseService
        self.userUID = userUID
        Task { await loadSessions() }
    }

    func loadSessions() async {
        // Load locally
        sessions = coreDataService.fetchSwingSessions()
        // Sync with Firebase
        await syncWithFirebase()
    }

    func syncWithFirebase() async {
        do {
            let remoteSessions = try await firebaseService.fetchAllSwingSessions(forUser: userUID)
            
            // Save fetched sessions to Core Data
            for session in remoteSessions {
                coreDataService.saveSwingSession(session)
            }
            
            // Reload sessions from Core Data
            sessions = coreDataService.fetchSwingSessions()
        } catch let error as NSError {
            print("Failed to sync sessions: \(error.localizedDescription)")
            if error.code == 7 {
                print("Permission denied. Check Firestore security rules.")
            }
        }
    }

    func addSession(_ session: SwingSession) async {
        var newSession = session
        newSession.userUID = userUID 

        coreDataService.saveSwingSession(newSession)
        do {
            try await firebaseService.saveSwingSession(newSession, userUID: userUID)
        } catch {
            print("Failed to save session to Firebase: \(error)")
        }
        await loadSessions()
    }

    func deleteSession(_ session: SwingSession) async {
        coreDataService.deleteSwingSession(session)
        if let firebaseUID = session.firebaseUID {
            do {
                try await firebaseService.deleteSwingSession(uid: firebaseUID)
            } catch {
                print("Failed to delete session from Firebase: \(error)")
            }
        }
        await loadSessions()
    }
}
