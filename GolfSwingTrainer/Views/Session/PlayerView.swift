//
//  PlayerView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-04.
//

import AVKit
import SwiftUI

struct PlayerView: View {
    @State private var viewModel = PlayerViewModel()
    
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
        }
    }
}

#Preview {
    PlayerView()
}
