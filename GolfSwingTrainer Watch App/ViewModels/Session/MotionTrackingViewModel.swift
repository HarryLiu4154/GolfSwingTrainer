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
    let motionManager = CMMotionManager() // Core Motion Manager
    var session: WCSession? // Watch Connectivity Session

    @Published var isTracking = false // Tracks if motion tracking is active
    @Published var latestMotionData: MotionData? // The latest motion data to display

    var motionDataBuffer: [MotionData] = [] // Buffer to store motion data

    override init() {
        super.init()
        setupWatchConnectivity()
    }

    // Setup WatchConnectivity session
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
                guard let self = self, let motion = motion else {
                    print("Error receiving motion data: \(String(describing: error?.localizedDescription))")
                    return
                }

                // Capture motion data and update the buffer
                let data = MotionData(
                    rotationRate: ["x": motion.rotationRate.x, "y": motion.rotationRate.y, "z": motion.rotationRate.z],
                    userAcceleration: ["x": motion.userAcceleration.x, "y": motion.userAcceleration.y, "z": motion.userAcceleration.z],
                    timestamp: motion.timestamp
                )
                self.motionDataBuffer.append(data)
                self.latestMotionData = data
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

    // Send motion data to the iOS device
    func sendMotionDataToPhone() {
        guard let session = session, session.isReachable else {
            print("iOS device is not reachable.")
            return
        }

        do {
            let data = try JSONEncoder().encode(motionDataBuffer)
            session.sendMessageData(data, replyHandler: nil, errorHandler: { error in
                print("Error sending motion data: \(error.localizedDescription)")
            })
            print("Motion data sent to iOS.")
            motionDataBuffer.removeAll() // Clear the buffer after sending
        } catch {
            print("Failed to encode motion data: \(error.localizedDescription)")
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("Received message from iPhone: \(message)")
    }
}
