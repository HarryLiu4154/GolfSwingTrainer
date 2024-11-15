//
//  MotionData.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-10-18.
//

import CoreMotion
import SwiftUI
import UIKit
import WatchConnectivity

class MotionData: ObservableObject {
    @Published var motion: CMMotionManager?
    
    init() {
        motion = CMMotionManager()
    }
}

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }
    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        if let error = error {
//            print("WCSession activation failed with error: \(error.localizedDescription)")
//            return
//        }
//        print("WCSession activated successfully with state: \(activationState.rawValue)")
//    }
//    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        if let motionData = message["motionData"] as? [String: Double] {
//            print("Received motion data: \(motionData)")
//        }
//    }
    
    var onMotionDataReceived: (([String: Double]) -> Void)?
        
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WCSession activated successfully.")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle incoming messages, such as motion data from the Apple Watch
        if let motionData = message["motionData"] as? [String: Double] {
            DispatchQueue.main.async {
                self.onMotionDataReceived?(motionData)
            }
        }
    }
}
