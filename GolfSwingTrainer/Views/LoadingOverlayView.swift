//
//  LoadingOverlayView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import SwiftUI

///This view can be used as an overlay on any screen to display a loading indicator with a message
struct LoadingOverlayView: View {
    let message: String
        
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5) // Make it larger
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(40)
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}

#Preview {
    LoadingOverlayView(message: "Saving...")
}
