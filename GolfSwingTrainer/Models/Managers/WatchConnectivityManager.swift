//
//  WatchConnectivityManager.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//
import WatchConnectivity
import Foundation

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var swingSessionViewModel: SwingSessionViewModel?

    init(swingSessionViewModel: SwingSessionViewModel) {
        self.swingSessionViewModel = swingSessionViewModel
        super.init()
        setupWatchConnectivity()
    }

    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let session = try JSONDecoder().decode(SwingSession.self, from: messageData)
            Task {
                await swingSessionViewModel?.addSession(session)
            }
        } catch {
            print("Failed to decode Swing Session: \(error.localizedDescription)")
        }
    }

    // Required WCSessionDelegate methods
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
