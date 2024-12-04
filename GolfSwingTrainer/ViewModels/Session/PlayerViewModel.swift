//
//  PlayerViewModel.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-04.
//

import AVKit
import SwiftUI

@Observable
class PlayerViewModel {
    var player: AVPlayer?
    var playbackRate: Float = 1.0
    
    init() {
        player = AVPlayer(url: .documentsDirectory.appending(path: "abode.MOV"))
    }
}
