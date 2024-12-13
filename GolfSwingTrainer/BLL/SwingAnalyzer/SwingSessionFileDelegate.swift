//
//  SwingSessionFileDelegate.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-11-21.
//

import AVFoundation

class SwingSessionFileDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        print("saved to \(outputFileURL) ? : \(error)")
    }
}
