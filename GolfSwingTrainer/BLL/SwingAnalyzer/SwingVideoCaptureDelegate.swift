//
//  SwingVideoCaptureDelegate.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-16.
//

import AVFoundation
import SceneKit
import UIKit
import Vision

@Observable
class SwingVideoCaptureDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var outputFrame: CGImage?
    var outputScene: SCNScene?
    var bodyHeight: Float?
    
    private let defaultScene = SCNScene(named: "MyScene3.scn", inDirectory: "SceneKit Asset Catalog.scnassets")
    private let modelScene = SCNScene(named: "Humanoid", inDirectory: "SceneKit Asset Catalog.scnassets")
    private var firstTime = false
    private var modelNode: SCNNode {
        if !firstTime{
            return SCNNode()
        }else{
            return modelScene!.rootNode
        }
    }
    
    var fileOutput = AVCaptureMovieFileOutput()
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("!!!!!!!!!!!!!!!!!!!!!!!")
        do {
            let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = docDir.appendingPathComponent(UUID().uuidString + ".mov")
            print(fileURL)
            self.fileOutput.startRecording(to: URL.moviesDirectory.appendingPathComponent("aaa.mov"), recordingDelegate: SwingSessionFileDelegate())
        } catch {
        }
        guard let cvBuffer = sampleBuffer.imageBuffer else { return }
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }
        //        self.outputFrame = findPose(cgImage: cgImage)
        self.outputScene = doScene(sampleBuffer: sampleBuffer)
    }
    
    func doScene(sampleBuffer: CMSampleBuffer) -> SCNScene? {
        print(defaultScene!.rootNode.childNodes.count)
        if defaultScene != nil{
            if !firstTime {
                firstTime = true
                defaultScene!.rootNode.addChildNode(modelNode)
                print(modelNode)
                print(modelNode.childNodes)
            }
            let jaw = modelNode.childNode(withName: "mixamorig_Jaw", recursively: true)
            let pose = realFindPose(sampleBuffer: sampleBuffer)
            if let foundPose = pose.first {
                do{
                    let headPos = try foundPose.recognizedPoint(.centerHead).localPosition
                    print(headPos[3][0])
                    jaw!.position = SCNVector3(headPos[3][0] * 200, 0, 0)
                }catch{
                }
            }
        }
        return defaultScene
    }
    
    func realFindPose(sampleBuffer: CMSampleBuffer) -> [VNHumanBodyPose3DObservation] {
        let request = VNDetectHumanBodyPose3DRequest()
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
        do{
            try requestHandler.perform([request])
            return request.results ?? []
        }catch{
            print("VNDetectHumanBodyPose3DRequest failed :(")
        }
        return []
    }
    
    func findPose(cgImage: CGImage) -> CGImage {
        let request = VNDetectHumanBodyPose3DRequest()
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        do{
            try requestHandler.perform([request])
            if let returnedObservation = request.results?.first{
                self.bodyHeight = returnedObservation.bodyHeight
                let availableJoints = returnedObservation.availableJointNames
                guard let context = CGContext(data: nil, width: cgImage.width, height: cgImage.height, bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: cgImage.bytesPerRow, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return cgImage }
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
                context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 0.5))
                for availableJoint in availableJoints {
                    let point = try returnedObservation.pointInImage(availableJoint)
                    let cgPoint = CGPoint(x: point.x * Double(cgImage.width), y: point.y * Double(cgImage.height))
                    context.fillEllipse(in: CGRect(origin: cgPoint, size: CGSize(width: 50, height: 50)))
                }
                return context.makeImage() ?? cgImage
            }else{
                self.bodyHeight = nil
            }
        }catch{
            print("request failed")
        }
        return cgImage
    }
}
