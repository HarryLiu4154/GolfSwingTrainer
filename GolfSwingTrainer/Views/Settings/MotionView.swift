//
//  MotionView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-23.
//

import SwiftUI

struct MotionView: View {
    @StateObject private var viewModel = MotionDataReceiverViewModel()

    var body: some View {
        NavigationStack {
            NavigationStack {
                List(viewModel.receivedMotionData) { data in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Timestamp: \(data.timestamp)")
                            .font(.caption)
                        Text("Rotation Rate: x=\(data.rotationRate["x"] ?? 0.0), y=\(data.rotationRate["y"] ?? 0.0), z=\(data.rotationRate["z"] ?? 0.0)")
                            .font(.caption)
                        Text("Acceleration: x=\(data.userAcceleration["x"] ?? 0.0), y=\(data.userAcceleration["y"] ?? 0.0), z=\(data.userAcceleration["z"] ?? 0.0)")
                            .font(.caption)
                        Text("Attitude: Roll=\(data.attitude["roll"] ?? 0.0), Pitch=\(data.attitude["pitch"] ?? 0.0), Yaw=\(data.attitude["yaw"] ?? 0.0)")
                            .font(.caption)
                    }
                }
                .navigationTitle("Motion Data")
            }
        }
    }
}

#Preview {
    MotionView()
}
