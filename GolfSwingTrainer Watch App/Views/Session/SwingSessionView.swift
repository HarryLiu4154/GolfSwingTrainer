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
        VStack {
            Text("Motion Tracking")
                .font(.headline)
            
            Text("Rotation Rate: \(viewModel.rotationRate.x), \(viewModel.rotationRate.y), \(viewModel.rotationRate.z)")
                .font(.footnote)
            Text("User Acceleration: \(viewModel.userAcceleration.x), \(viewModel.userAcceleration.y), \(viewModel.userAcceleration.z)")
                .font(.footnote)
            Text("Attitude: Roll \(viewModel.attitude.roll), Pitch \(viewModel.attitude.pitch), Yaw \(viewModel.attitude.yaw)")
                .font(.footnote)
            
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
    }
}


#Preview {
    SwingSessionView().environmentObject(MotionTrackingViewModel())
}
