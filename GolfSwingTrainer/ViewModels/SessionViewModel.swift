//
//  SessionViewModel.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-15.
//

import AVFoundation
import CoreImage
import SwiftUI

@Observable class SessionViewModel{//}: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice?
    private var videoStream = AVCaptureVideoDataOutput()
    private var captureDelegate = SwingVideoCaptureDelegate()
    
    var outputFrame: Image {
        guard let cgImage = captureDelegate.outputFrame else { return Image(systemName: "globe") }
        return Image(decorative: captureDelegate.outputFrame!, scale: 1, orientation: .up)
    }
    var bodyHeight: Float? {
        return captureDelegate.bodyHeight
    }
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }


    func setUpCaptureSession() async {
        guard await isAuthorized else { return }
        captureSession = AVCaptureSession()
        guard let videoDevice = AVCaptureDevice.userPreferredCamera else { return }
        self.videoDevice = videoDevice
        
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput)
        else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoStream = AVCaptureVideoDataOutput()
        videoStream.videoSettings = nil // default uncompressed format
        videoStream.setSampleBufferDelegate(captureDelegate, queue: DispatchQueue.global(qos: .userInteractive))
        guard captureSession.canAddOutput(videoStream) else { return }
        captureSession.addOutput(videoStream)
        
        captureSession.startRunning()
    }
    
    /*
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvBuffer = sampleBuffer.imageBuffer else { return }
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        self.outputFrame = UIImage(ciImage: ciImage, scale: 1, orientation: .up)
        
        /*
        let ciBuffer = CIImage(cvImageBuffer: imageBuffer)
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciBuffer, from: ciBuffer.extent) else { return }
        self.outputImage = Image(*/
    }*/
}
