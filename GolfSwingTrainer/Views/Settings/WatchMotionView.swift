//
//  WatchMotionView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import SwiftUI
import Foundation
struct WatchMotionView: View {
    @StateObject private var viewModel = MotionDataViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.motionData, id: \.timestamp) { data in
                VStack(alignment: .leading) {
                    Text("Timestamp: \(data.timestamp)")
                    Text("Rotation Rate: \(data.rotationRate)")
                    Text("Acceleration: \(data.userAcceleration)")
                }
            }
            .navigationTitle("Motion Data")
        }
    }
}

#Preview {
    WatchMotionView()
}
