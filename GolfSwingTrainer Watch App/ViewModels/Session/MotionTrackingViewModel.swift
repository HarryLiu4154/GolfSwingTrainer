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
                guard let self = self, let motion = motion, error == nil else { return }
                let rotation = motion.rotationRate
                let acceleration = motion.userAcceleration
                let attitude = motion.attitude
                
                self.rotationRate = rotation
                self.userAcceleration = acceleration
                self.attitude = attitude
                
                // Save the data for later
                self.motionData.append((rotation: rotation, acceleration: acceleration, attitude: attitude, timestamp: motion.timestamp))
            }
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
            session.sendMessage(["motionData": dataToSend], replyHandler: nil, errorHandler: nil)
        } else {
            print("iOS device is not reachable. Saving data locally.")
            // TODO: Implement local saving logic
        }
        
        motionData.removeAll() // Clear session data after saving
    }
    
    // WCSession Delegate Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch Connectivity activation failed: \(error.localizedDescription)")
        } else {
            print("Watch Connectivity activated")
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // TODO: Handle messages from iOS device.
    }
}
