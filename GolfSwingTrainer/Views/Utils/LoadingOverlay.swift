//
//  LoadingOverlay.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

import SwiftUI

struct LoadingOverlay: View {
    let isLoading: Bool
    let message: String

    var body: some View {
        Group {
            if isLoading {
                ZStack {
                    // Background overlay
                    Color.black.opacity(0.2)
                        .edgesIgnoringSafeArea(.all)

                    // Progress View with Message
                    VStack(spacing: 20) {
                        LoadingProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5) // Makes the spinner larger

                        Text(message)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .animation(.easeInOut, value: isLoading) // Smooth animation when appearing/disappearing
    }
}


#Preview {
    LoadingOverlay(isLoading: true, message: "Message")
}
