//
//  SessionViewModel.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-15.
//

import ARKit
import AVFoundation
import Combine
import CoreImage
import RealityKit
import SceneKit
import SwiftUI

class SessionViewModel: NSObject, ObservableObject, ARSessionDelegate {
    
    private var character: BodyTrackedEntity?
    private let characterOffset: SIMD3<Float> = [0.0, 0, 0] // Offset the character if wanted
    private let characterAnchor = AnchorEntity()
    
    private var sessionTransforms: SessionTransforms? = nil
    private let coreDataService: CoreDataService
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        super.init()
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "SceneKit Asset Catalog.scnassets/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
    }
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var recordingStartTime = 0.0
    private var hasCalledSinceRecording = false
    private var recordingSession: RecordingSession?

    @Published var isRecording = false
    @Published var outputARView = ARView()
    
    private var isAVAuthorized: Bool {
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
    
    private func setUpARCaptureSession() {
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        outputARView.session.delegate = self
        
        // Run a body tracking configuration.
        let configuration = ARBodyTrackingConfiguration()
        outputARView.session.run(configuration)
        print(configuration)
        print(self.coreDataService.fetchRecordingSessions())
    }
    
    private func startAR() {
        outputARView.scene.addAnchor(self.characterAnchor)
    }
    
    private func stopAR() {
        outputARView.scene.removeAnchor(self.characterAnchor)
    }
    
    private func startRecording() {
        let date = Date()
        let videoURL = URL.documentsDirectory.appending(path: "Session\(date.timeIntervalSince1970).mov")
        if let assetWriter = try? AVAssetWriter(url: videoURL, fileType: .mov) {
            self.recordingSession = RecordingSession(userUID: nil, date: date, videoURL: videoURL, timestampData: [TimeInterval](), speedData: [Double]())
            let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: AVOutputSettingsAssistant(preset: .preset1920x1080)?.videoSettings)
            assetWriterInput.expectsMediaDataInRealTime = true
            assetWriter.add(assetWriterInput)
            
            guard assetWriter.startWriting() else {
                print("Couldn't start AVAssetWriter wrinting")
                return
            }
            assetWriter.startSession(atSourceTime: .zero)
            
            self.hasCalledSinceRecording = false
            self.assetWriterInput = assetWriterInput
            self.assetWriter = assetWriter
        }
    }
    
    private func stopRecording() {
        self.assetWriterInput?.markAsFinished()
        self.assetWriter?.finishWriting {
            self.assetWriterInput = nil
            self.assetWriter = nil
            if self.recordingSession != nil {
                self.coreDataService.saveRecordingSession(self.recordingSession!)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard self.isRecording && (self.assetWriter != nil) && (self.assetWriterInput != nil) else { return }
        guard self.assetWriter!.status == .writing else { return }
        guard self.assetWriterInput!.isReadyForMoreMediaData else { return }
        if !self.hasCalledSinceRecording {
            self.hasCalledSinceRecording = true
            self.recordingStartTime = frame.timestamp
        }
        // questions/47993457
        let scale = CMTimeScale(NSEC_PER_SEC)
        let pts = CMTime(value: CMTimeValue((frame.timestamp-self.recordingStartTime) * Double(scale)), timescale: scale)
        let timingInfo = CMSampleTimingInfo(duration: .invalid, presentationTimeStamp: pts, decodeTimeStamp: .invalid)
        if let cmBuffer = try? CMSampleBuffer(imageBuffer: frame.capturedImage, formatDescription: CMFormatDescription(imageBuffer: frame.capturedImage), sampleTiming: timingInfo) {
            self.assetWriterInput!.append(cmBuffer)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard self.isRecording else { return }
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            if let rightHandTransform = bodyAnchor.skeleton.localTransform(for: .rightHand), let leftHandTransform = bodyAnchor.skeleton.localTransform(for: .leftHand), let timestamp = session.currentFrame?.timestamp {
                
                if self.sessionTransforms == nil {
                    self.sessionTransforms = SessionTransforms(initialWorldTransform: bodyAnchor.transform, initialRightHandTransform: rightHandTransform, initialLeftHandTransform: leftHandTransform, initialTimestamp: timestamp)
                } else {
                    let avgSpeed = sessionTransforms!.calculateUpdateSpeed(newWorldTransform: bodyAnchor.transform, newRightHandTransform: rightHandTransform, newLeftHandTransform: leftHandTransform, newTimestamp: timestamp)
                    self.recordingSession?.timestampData.append(timestamp)
                    self.recordingSession?.speedData.append(avgSpeed)
                }
            }

            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition //+ characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
            
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
        }
    }
    
    func setup() async {
        setUpARCaptureSession()
    }

    func startCapture() {
        self.isRecording = true
        self.sessionTransforms = nil
        startAR()
        startRecording()
    }
    
    func stopCapture() {
        stopAR()
        stopRecording()
        self.sessionTransforms = nil
        self.isRecording = false
    }
}
