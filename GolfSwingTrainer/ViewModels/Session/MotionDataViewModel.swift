//
//  MotionDataViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation
import WatchConnectivity

///Manages Motion Data settings example
class MotionDataViewModel: NSObject, ObservableObject, WCSessionDelegate {
    
    func groupMotionDataByTimestamp(_ motionData: [MotionData], threshold: TimeInterval = 0.02) -> [[MotionData]] {
        guard !motionData.isEmpty else { return [] }
        
        let sortedData = motionData.sorted { $0.timestamp < $1.timestamp }
        
        var groupedData: [[MotionData]] = []
        var currentGroup: [MotionData] = [sortedData.first!]
        
        for i in 1..<sortedData.count {
            let currentData = sortedData[i]
            let previousData = sortedData[i - 1]
            
            // Check if the difference in timestamps is within the threshold
            if currentData.timestamp - previousData.timestamp <= threshold {
                currentGroup.append(currentData)
            } else {
                // Start a new group
                groupedData.append(currentGroup)
                currentGroup = [currentData]
            }
        }
        
        // Add the last group
        if !currentGroup.isEmpty {
            groupedData.append(currentGroup)
        }
        
        return groupedData
    }

    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //Auto generated
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //Auto generated
    }
    
    @Published var groupedMotionData: [[MotionData]] = []
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
                self.groupedMotionData = self.groupMotionDataByTimestamp(data)
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
