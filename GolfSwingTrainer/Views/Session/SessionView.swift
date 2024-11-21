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
    @State private var isRecording = false
    
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
            VStack{
                Spacer()
                Button(action:{
                    if isRecording {
                        viewModel.stopCapture()
                        isRecording = false
                    } else {
                        isRecording = true
                        viewModel.startCapture()
                    }
                }, label: {
                    Text("")
                        .font(.title2)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .background(.red)
                        .clipShape(Circle())
                })
            }
        }
        .task {
            await viewModel.setup()
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
