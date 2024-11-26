//
//  SwingSessionListView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//
import SwiftUI
import Foundation

struct SwingSessionListView: View {
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel

    var body: some View {
        NavigationView {
            List(swingSessionViewModel.sessions) { session in
                NavigationLink(destination: MotionDataDetailView(session: session)) {
                    VStack(alignment: .leading) {
                        Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                        Text("Rotation Samples: \(session.rotationData.count)")
                        Text("Acceleration Samples: \(session.accelerationData.count)")
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
