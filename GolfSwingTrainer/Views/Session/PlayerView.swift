//
//  PlayerView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-04.
//

import AVKit
import SwiftUI

struct PlayerView: View {
    @State var viewModel: PlayerViewModel
    
    var body: some View {
        VStack {
            VideoPlayer(player: viewModel.player) {
                VStack {
                    Spacer()
                    Slider(value: $viewModel.playbackRate, in: 0...1, step: 0.05)
                        .onChange(of: viewModel.playbackRate, initial: false) { oldRate, newRate in
                            viewModel.player?.rate = newRate
                        }
                    Text(String(format: "Playback Rate: %.2f", viewModel.playbackRate))
                }
            }
            Text("Max Speed: \(viewModel.recordingSession.speedData.max() ?? 0) m/s")
        }
    }
}

#Preview {
    PlayerView(viewModel: PlayerViewModel(recordingSession: RecordingSession(userUID: nil, date: Date(), videoURL: URL.documentsDirectory.appending(path: "Session.mov"), timestampData: [0,1], speedData: [1,0])))
}
