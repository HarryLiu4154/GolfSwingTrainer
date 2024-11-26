//
//  MotionDataDetailView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//

import SwiftUI

struct MotionDataDetailView: View {
    let session: SwingSession

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                // Session metadata
                Text("Session Details")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Rotation Data
                Text("Rotation Data")
                    .font(.headline)
                if session.rotationData.isEmpty {
                    Text("No rotation data available.")
                        .foregroundColor(.gray)
                } else {
                    rotationDataView
                }
                
                Divider()
                
                // Acceleration Data
                Text("Acceleration Data")
                    .font(.headline)
                if session.accelerationData.isEmpty {
                    Text("No acceleration data available.")
                        .foregroundColor(.gray)
                } else {
                    accelerationDataView
                }
            }
            .padding()
        }
        .navigationTitle("Swing Session Details")
    }

    private var rotationDataView: some View {
        ForEach(session.rotationData.indices, id: \.self) { index in
            let rotation = session.rotationData[index]
            HStack {
                Text("Sample \(index + 1):")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text(rotationText(for: rotation))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var accelerationDataView: some View {
        ForEach(session.accelerationData.indices, id: \.self) { index in
            let acceleration = session.accelerationData[index]
            HStack {
                Text("Sample \(index + 1):")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text(accelerationText(for: acceleration))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func rotationText(for rotation: [String: Double]) -> String {
        let x = rotation["x"] ?? 0.0
        let y = rotation["y"] ?? 0.0
        let z = rotation["z"] ?? 0.0
        return "x: \(x), y: \(y), z: \(z)"
    }

    private func accelerationText(for acceleration: [String: Double]) -> String {
        let x = acceleration["x"] ?? 0.0
        let y = acceleration["y"] ?? 0.0
        let z = acceleration["z"] ?? 0.0
        return "x: \(x), y: \(y), z: \(z)"
    }
}

#Preview {
    MotionDataDetailView(session: SwingSession.MOCK_SESSION)
}
