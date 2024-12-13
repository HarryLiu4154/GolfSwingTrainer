//
//  SwingSessionListView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//
import SwiftUI
import Foundation

//struct SwingDataCalculationUtilities {
//    static func calculateAngle(from dataList: [[String: Double]]) -> Double? {
//        let angles = dataList.compactMap { data -> Double? in
//            guard let x = data["x"], let y = data["y"], let z = data["z"] else {
//                return nil
//            }
//            return sqrt(x * x + y * y + z * z)
//        }
//        
//        guard !angles.isEmpty else {
//            return nil // Return nil if no valid angles were calculated
//        }
//        
//        let total = angles.reduce(0, +)
//        return radTodeg(total / Double(angles.count))
//    }
//    
//    static func radTodeg(_ number: Double) -> Double {
//        return number * 180 / .pi
//    }
//    
//    static func calculateVelocity(from accelerationData: [[String: Double]]) -> Double? {
//        var velocityX = 0.0
//        var velocityY = 0.0
//        var velocityZ = 0.0
//        let deltaTime: Double = 0.02 // 50Hz or 0.02 seconds
//
//        for data in accelerationData {
//            guard let ax = data["x"], let ay = data["y"], let az = data["z"] else {
//                return nil // Invalid data
//            }
//            velocityX += ax * deltaTime
//            velocityY += ay * deltaTime
//            velocityZ += az * deltaTime
//        }
//
//        // Calculate the magnitude of the velocity vector
//        let velocity = sqrt(velocityX * velocityX + velocityY * velocityY + velocityZ * velocityZ)
//        return velocity
//    }
//}

struct SwingSessionListView: View {
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(swingSessionViewModel.sessions.sorted(by: { $0.date > $1.date })) { session in
                    NavigationLink(destination: MotionDataDetailView(session: session)) {
                        VStack(alignment: .leading) {
                            Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.headline)
//                            Text("\(session.rotationData.count) Rotation Samples, \(session.accelerationData.count) Acceleration Samples")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
                            
                            Text("Rotation: \(String(describing: SwingDataCalculationUtilities.calculateAngle(from: session.rotationData))) Degrees,\nSpeed: \(String(describing: SwingDataCalculationUtilities.calculateVelocity(from: session.accelerationData))) km/h")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Swing Sessions")
            .onAppear {
                Task {
                    await swingSessionViewModel.loadSessions()
                }
            }
        }
    }
}
#Preview{

}
