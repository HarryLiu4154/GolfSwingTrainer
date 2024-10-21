//
//  SessionView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-15.
//

import SwiftUI

struct SessionView: View {
    @State private var viewModel = SessionViewModel()
    
    var body: some View {
        ZStack{
            viewModel.outputFrame
                .resizable()
                .scaledToFit()
            Text("Height: \(viewModel.bodyHeight ?? .nan)m")
        }
        .task {
            await viewModel.setUpCaptureSession()
        }
    }
}

#Preview {
    SessionView()
}
