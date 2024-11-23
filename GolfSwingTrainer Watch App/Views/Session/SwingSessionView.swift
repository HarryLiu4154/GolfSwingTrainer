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
            VStack {
                Text("Motion Tracking")
                    .font(.headline)
                
                Text("Rotation Rate: \(String(format: "%.2f", viewModel.rotationRate.x)), \(String(format: "%.2f", viewModel.rotationRate.y)), \(String(format: "%.2f", viewModel.rotationRate.z))")
                    .font(.footnote)
                Text("User Acceleration: \(String(format: "%.2f", viewModel.userAcceleration.x)), \(String(format: "%.2f", viewModel.userAcceleration.y)), \(String(format: "%.2f", viewModel.userAcceleration.z))")
                    .font(.footnote)
                /*Text("Attitude: Roll \(String(format: "%.2f", viewModel.attitude.roll)), Pitch \(String(format: "%.2f", viewModel.attitude.pitch)), Yaw \(String(format: "%.2f", viewModel.attitude.yaw))")
                    .font(.footnote)*/
                
                Spacer()
                
                if viewModel.isTracking {
                    Button("Stop Tracking") {
                        viewModel.stopTracking()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Start Tracking") {
                        viewModel.startTracking()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Save Session") {
                    viewModel.saveSession()
                }
                .disabled(!viewModel.isTracking)
            }
            .padding()
            .onAppear {
                print("SwingSessionView appeared. Ready to track motion.")
            }
            .onDisappear {
                print("SwingSessionView disappeared. Stopping tracking.")
                viewModel.stopTracking()
            }
        }
    }
}


#Preview {
    SwingSessionView()
}
