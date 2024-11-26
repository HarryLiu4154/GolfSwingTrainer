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
        NavigationStack {
            List {
                ForEach(swingSessionViewModel.sessions.sorted(by: { $0.date > $1.date })) { session in
                    NavigationLink(destination: MotionDataDetailView(session: session)) {
                        VStack(alignment: .leading) {
                            Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.headline)
                            Text("\(session.rotationData.count) Rotation Samples, \(session.accelerationData.count) Acceleration Samples")
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
