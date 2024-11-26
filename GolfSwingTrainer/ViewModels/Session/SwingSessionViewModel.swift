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
            for session in remoteSessions {
                coreDataService.saveSwingSession(session)
            }
            sessions = coreDataService.fetchSwingSessions()
        } catch {
            print("Failed to sync sessions: \(error)")
        }
    }

    func addSession(_ session: SwingSession) async {
        coreDataService.saveSwingSession(session)
        do {
            try await firebaseService.saveSwingSession(session, userUID: userUID)
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
