//
//  MotionDataDetailView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//

import SwiftUI
import CoreMotion
import Foundation

struct MotionDataDetailView: View {
    let session: SwingSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Session Details")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                Text("Date: \(session.date.formatted())")
                    .font(.subheadline)
                    .padding(.bottom, 10)
                
                Text("Rotation Data:")
                    .font(.headline)
                    .padding(.bottom, 5)
                ForEach(session.rotationData, id: \.self) { rotation in
                    Text("x: \(rotation["x"] ?? 0.0), y: \(rotation["y"] ?? 0.0), z: \(rotation["z"] ?? 0.0)")
                        .font(.footnote)
                        .padding(.bottom, 2)
                }
                
                Text("Acceleration Data:")
                    .font(.headline)
                    .padding(.top, 10)
                ForEach(session.accelerationData, id: \.self) { acceleration in
                    Text("x: \(acceleration["x"] ?? 0.0), y: \(acceleration["y"] ?? 0.0), z: \(acceleration["z"] ?? 0.0)")
                        .font(.footnote)
                        .padding(.bottom, 2)
                }
            }
            .padding()
        }
        .navigationTitle("Session Details")
    }
}

#Preview {
   
}
