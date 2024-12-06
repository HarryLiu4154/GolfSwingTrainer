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
    @EnvironmentObject var viewModel: SessionViewModel
    
    @State private var recordingIconOpacity = 1.0
    
    var body: some View {
        ZStack{
            VStack{
                ARViewWrapper(arView: viewModel.outputARView)
            }
            VStack{
                HStack {
                    if viewModel.isRecording {
                        Circle()
                            .fill(.red)
                            .opacity(recordingIconOpacity)
                            .frame(width: 25, height: 25)
                            .onAppear {
                                withAnimation(.easeInOut.repeatForever(autoreverses: true)) {
                                    self.recordingIconOpacity = 0.0
                                }
                            }
                    }
                    Spacer()
                }
                Spacer()
                Button(action:{
                    if viewModel.isRecording {
                        viewModel.stopCapture()
                    } else {
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
        .environmentObject(SessionViewModel(coreDataService: CoreDataService()))
}
