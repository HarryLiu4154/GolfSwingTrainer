//
//  MotionManager.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-10-18.
//

import WatchKit
import CoreMotion
import WatchConnectivity

class MotionManager: NSObject, WCSessionDelegate {
    private let motionManager = CMMotionManager()
    private var session: WCSession?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func startTrackingMotionData() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data, error == nil else { return }
            let motionData: [String: Double] = [
                "x": data.acceleration.x,
                "y": data.acceleration.y,
                "z": data.acceleration.z
            ]
            
            self?.sendMotionDataToiPhone(motionData)
        }
    }

    private func sendMotionDataToiPhone(_ data: [String: Double]) {
        session?.sendMessage(["motionData": data], replyHandler: nil, errorHandler: { error in
            print("Error sending motion data: \(error.localizedDescription)")
        })
    }
    
    // WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        }
    }
}
