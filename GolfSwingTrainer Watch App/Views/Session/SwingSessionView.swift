//
//  SwingSessionView.swift
//  GolfSwingTrainer Watch App
//
//  Created by David Romero on 2024-10-02.
//

import SwiftUI
import WatchKit

struct SwingSessionView: View {
    @StateObject private var viewModel = MotionTrackingViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Motion Tracking")
                    .font(.headline)

                if let data = viewModel.latestMotionData {
                    Text("Rotation Rate: \(data.rotationRate)")
                    Text("User Acceleration: \(data.userAcceleration)")
                } else {
                    Text("No motion data yet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(viewModel.isTracking ? "Stop Tracking" : "Start Tracking") {
                    if viewModel.isTracking {
                        viewModel.stopTracking()
                    } else {
                        viewModel.startTracking()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isTracking ? .red : .blue)

                Button("Send Data to iPhone") {
                    viewModel.sendMotionDataToPhone()
                }
                .disabled(viewModel.motionDataBuffer.isEmpty)
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}


#Preview {
    SwingSessionView()
}
