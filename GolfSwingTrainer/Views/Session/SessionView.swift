//
//  SessionView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-15.
//

import RealityKit
import SceneKit
import SwiftUI

struct SessionView: View {
    @State private var viewModel = SessionViewModel()
    
    var body: some View {
//        let sceneOptions: SceneView.Options = [.autoenablesDefaultLighting]
        ZStack{
            VStack{
                ARViewWrapper(arView: viewModel.outputARView)
//                SceneView(scene: viewModel.outputScene, options: sceneOptions)
//                        viewModel.outputFrame
//                            .resizable()
//                            .scaledToFit()
        }
//            Text("Height: \(viewModel.bodyHeight ?? .nan)m")
        }
        .task {
            viewModel.setUpARCaptureSession()
//            await viewModel.setUpAVCaptureSession()
        }
    }
}

struct ARViewWrapper: UIViewRepresentable {
    let arView: ARView
    func makeUIView(context: Context) -> ARView {
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

#Preview {
    SessionView()
}
