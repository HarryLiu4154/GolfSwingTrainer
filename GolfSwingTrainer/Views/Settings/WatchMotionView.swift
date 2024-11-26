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

struct WatchMotionView: View {
    @StateObject private var viewModel = MotionDataViewModel()
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel

    var body: some View {
        NavigationView {
            List(viewModel.motionData, id: \.timestamp) { data in
                VStack(alignment: .leading) {
                    Text("Timestamp: \(Date(timeIntervalSince1970: data.timestamp).formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Rotation Rate: x: \(data.rotationRate["x"] ?? 0.0, specifier: "%.2f"), y: \(data.rotationRate["y"] ?? 0.0, specifier: "%.2f"), z: \(data.rotationRate["z"] ?? 0.0, specifier: "%.2f")")
                        .font(.footnote)
                    Text("Acceleration: x: \(data.userAcceleration["x"] ?? 0.0, specifier: "%.2f"), y: \(data.userAcceleration["y"] ?? 0.0, specifier: "%.2f"), z: \(data.userAcceleration["z"] ?? 0.0, specifier: "%.2f")")
                        .font(.footnote)
                }
            }
            .navigationTitle("Motion Data")
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
