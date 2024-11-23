//
//  MotionTrackingViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-20.
//

import Foundation
import CoreMotion
import WatchConnectivity

class MotionTrackingViewModel: NSObject, ObservableObject, WCSessionDelegate {
    // Core Motion Manager
    private let motionManager = CMMotionManager()
    
    // Published properties for real-time UI updates
    @Published var rotationRate: CMRotationRate = CMRotationRate()
    @Published var userAcceleration: CMAcceleration = CMAcceleration()
    @Published var attitude: CMAttitude = CMAttitude()
    @Published var isTracking = false
    
    // Storage for session data
    private var motionData: [(rotation: CMRotationRate, acceleration: CMAcceleration, attitude: CMAttitude, timestamp: TimeInterval)] = []
    
    // Watch Connectivity Session
    private var session: WCSession?
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    // Initialize Watch Connectivity
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    // Start tracking motion data
    func startTracking() {
        guard !isTracking else { return }
        isTracking = true
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 50.0 // 50 Hz
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let self = self, let motion = motion, error == nil else {
                    print("Error receiving motion data: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                DispatchQueue.main.async {
                    self.rotationRate = motion.rotationRate
                    self.userAcceleration = motion.userAcceleration
                    self.attitude = motion.attitude
                    
                    // Save data for later
                    self.motionData.append((rotation: motion.rotationRate, acceleration: motion.userAcceleration, attitude: motion.attitude, timestamp: motion.timestamp))
                }
            }
        } else {
            print("Device motion is not available.")
        }
    }
    
    // Stop tracking motion data
    func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        motionManager.stopDeviceMotionUpdates()
    }
    
    // Save data locally or send to iOS
    func saveSession() {
        guard !motionData.isEmpty else { return }
        
        let dataToSend = motionData.map { data in
            return [
                "rotationRate": ["x": data.rotation.x, "y": data.rotation.y, "z": data.rotation.z],
                "userAcceleration": ["x": data.acceleration.x, "y": data.acceleration.y, "z": data.acceleration.z],
                "attitude": ["roll": data.attitude.roll, "pitch": data.attitude.pitch, "yaw": data.attitude.yaw],
                "timestamp": data.timestamp
            ]
        }
        
        if let session = session, session.isReachable {
            session.sendMessage(["motionData": dataToSend], replyHandler: nil, errorHandler: { error in
                print("Error sending motion data to iPhone: \(error.localizedDescription)")
            })
        } else {
            print("iOS device is not reachable. Data not sent.")
        }
        
        motionData.removeAll() // Clear session data after saving
    }
    
    // WCSession Delegate Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from iPhone: \(message)")
        // TODO: Handle received data
    }
}
