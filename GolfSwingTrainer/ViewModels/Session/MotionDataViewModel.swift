//
//  MotionDataViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation
import WatchConnectivity

///Manages WatchConnectivity with watch Device
class MotionDataViewModel: NSObject, ObservableObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        //Auto generated
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //Auto generated
    }
    
    @Published var motionData: [MotionData] = []

    override init() {
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
            let data = try JSONDecoder().decode([MotionData].self, from: messageData)
            DispatchQueue.main.async {
                self.motionData = data
                print("Motion data received: \(data)")
            }
        } catch {
            print("Failed to decode motion data: \(error.localizedDescription)")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
}
