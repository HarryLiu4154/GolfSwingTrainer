//
//  WatchMotionView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import SwiftUI
import Foundation
import CoreMotion
import FirebaseAuth

struct SwingDataCalculationUtilities {
    static func extractRotation(from motionData: [MotionData]) -> [[String: Double]] {
        return motionData.map { $0.rotationRate }
    }
    
    static func extractAcceleration(from motionData: [MotionData]) -> [[String: Double]] {
        return motionData.map { $0.userAcceleration }
    }
    
    static func calculateAngle(from dataList: [[String: Double]]) -> Double? {
        let angles = dataList.compactMap { data -> Double? in
            guard let x = data["x"], let y = data["y"], let z = data["z"] else {
                return nil
            }
            return sqrt(x * x + y * y + z * z)
        }
        
        guard !angles.isEmpty else {
            return nil // Return nil if no valid angles were calculated
        }
        
        let total = angles.reduce(0, +)
        return radTodeg(total / Double(angles.count))
    }
    
    static func radTodeg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    static func calculateVelocity(from accelerationData: [[String: Double]]) -> Double? {
        var velocityX = 0.0
        var velocityY = 0.0
        var velocityZ = 0.0
        let deltaTime: Double = 0.02 // 50Hz or 0.02 seconds

        for data in accelerationData {
            guard let ax = data["x"], let ay = data["y"], let az = data["z"] else {
                return nil // Invalid data
            }
            velocityX += ax * deltaTime
            velocityY += ay * deltaTime
            velocityZ += az * deltaTime
        }

        // Calculate the magnitude of the velocity vector
        let velocity = sqrt(velocityX * velocityX + velocityY * velocityY + velocityZ * velocityZ)
        return velocity
    }
}

struct WatchMotionView: View {
    @EnvironmentObject var viewModel: MotionDataViewModel
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel

    var body: some View {
        NavigationView {
//            List(viewModel.motionData, id: \.timestamp) { data in
//                VStack(alignment: .leading) {
//                    Text("Timestamp: \(Date(timeIntervalSince1970: data.timestamp).formatted(date: .abbreviated, time: .shortened))")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    Text("Rotation Rate: x: \(data.rotationRate["x"] ?? 0.0, specifier: "%.2f"), y: \(data.rotationRate["y"] ?? 0.0, specifier: "%.2f"), z: \(data.rotationRate["z"] ?? 0.0, specifier: "%.2f")")
//                        .font(.footnote)
//                    Text("Acceleration: x: \(data.userAcceleration["x"] ?? 0.0, specifier: "%.2f"), y: \(data.userAcceleration["y"] ?? 0.0, specifier: "%.2f"), z: \(data.userAcceleration["z"] ?? 0.0, specifier: "%.2f")")
//                        .font(.footnote)
//                }
//            }
            
            List(viewModel.groupedMotionData, id: \.first?.timestamp) { data in
                VStack(alignment: .leading) {
                    Text("Timestamp: \(Date(timeIntervalSince1970: data[0].timestamp).formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("Angle: \(SwingDataCalculationUtilities.calculateAngle( from: SwingDataCalculationUtilities.extractRotation(from: data)) ?? 90) degrees")
                        .font(.footnote)
                    
                    Text("Speed: \(SwingDataCalculationUtilities.calculateVelocity(from: SwingDataCalculationUtilities.extractAcceleration(from: data)) ?? 90) km/s")
                        .font(.footnote)
                }
            }
            .navigationTitle("Tracked Swings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sync") {
                        Task {
                            await syncMotionData()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sync Motion Data
    private func syncMotionData() async {
        guard !viewModel.motionData.isEmpty else {
            print("No motion data to sync.")
            return
        }

        let rotationData = viewModel.motionData.map { CMRotationRate(x: $0.rotationRate["x"] ?? 0.0, y: $0.rotationRate["y"] ?? 0.0, z: $0.rotationRate["z"] ?? 0.0) }
        let accelerationData = viewModel.motionData.map { CMAcceleration(x: $0.userAcceleration["x"] ?? 0.0, y: $0.userAcceleration["y"] ?? 0.0, z: $0.userAcceleration["z"] ?? 0.0) }

        guard let userUID = Auth.auth().currentUser?.uid else {
            print("No authenticated user found.")
            return
        }

        let newSession = SwingSession(
            userUID: userUID,
            date: Date(),
            rotationData: rotationData,
            accelerationData: accelerationData
        )

        do {
            print("Attempting to save new session: \(newSession)")
            await swingSessionViewModel.addSession(newSession)
            print("Motion data synced successfully!")
        } catch {
            print("Error syncing motion data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    WatchMotionView()
        .environmentObject(SwingSessionViewModel(
            coreDataService: CoreDataService(),
            firebaseService: FirebaseService(),
            userUID: "mockUserUID"
        ))
}
