//
//  MotionDataView.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-10-18.
//
import SwiftUI
import WatchConnectivity

struct MotionDataView: View {
    @State var motionData: [String: Double] = [:]
    var sessionDelegate = WatchSessionDelegate()

    var body: some View {
        VStack {
            Text("Motion Data")
                .font(.largeTitle)
            Text("x: \(motionData["x"] ?? 0.0)")
            Text("y: \(motionData["y"] ?? 0.0)")
            Text("z: \(motionData["z"] ?? 0.0)")
        }
        .onAppear {
            sessionDelegate.onMotionDataReceived = { data in
                motionData = data
            }
        }
    }
}
