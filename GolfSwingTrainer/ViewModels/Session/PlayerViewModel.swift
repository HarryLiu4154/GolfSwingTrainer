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
    let recordingSession: RecordingSession
    var player: AVPlayer?
    var playbackRate: Float = 1.0
    
    init(recordingSession: RecordingSession) {
        self.recordingSession = recordingSession
        print(recordingSession.videoURL)
        if let videoURL = recordingSession.videoURL {
            self.player = AVPlayer(url: URL.documentsDirectory.appending(path: videoURL.lastPathComponent))
        }
    }
}
