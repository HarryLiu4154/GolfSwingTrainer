//
//  SessionViewModel.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-15.
//

import ARKit
import AVFoundation
import CoreImage
import RealityKit
import SceneKit
import SwiftUI

@Observable
class SessionViewModel{
    
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice?
    private var videoStream = AVCaptureVideoDataOutput()
    private var avCaptureDelegate = SwingVideoCaptureDelegate()
    private var arCaptureDelegate = SwingARCaptureDelegate()
    
    var outputARView = ARView()
    var outputScene: SCNScene? {
        return avCaptureDelegate.outputScene
    }
    //    var outputFrame: Image {
    //        guard let cgImage = captureDelegate.outputFrame else { return Image(systemName: "globe") }
    //        return Image(decorative: captureDelegate.outputFrame!, scale: 1, orientation: .up)
    //    }
    var bodyHeight: Float? {
        return avCaptureDelegate.bodyHeight
    }
    
    var isAVAuthorized: Bool {
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
    
    func setUpARCaptureSession() {
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        outputARView.session.delegate = self.arCaptureDelegate
        
        // Run a body tracking configuration.
        let configuration = ARBodyTrackingConfiguration()
        outputARView.session.run(configuration)
        
        outputARView.scene.addAnchor(arCaptureDelegate.characterAnchor)
    }

    func setUpAVCaptureSession() async {
        guard await isAVAuthorized else { return }
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
        videoStream.setSampleBufferDelegate(avCaptureDelegate, queue: DispatchQueue.global(qos: .userInteractive))
        guard captureSession.canAddOutput(videoStream) else { return }
        captureSession.addOutput(videoStream)
        
        captureSession.startRunning()
    }
}