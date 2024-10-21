//
//  SwingVideoCaptureDelegate.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-10-16.
//

import AVFoundation
import UIKit
import Vision

@Observable
class SwingVideoCaptureDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var outputFrame: CGImage?
    var bodyHeight: Float?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvBuffer = sampleBuffer.imageBuffer else { return }
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }
        self.outputFrame = findPose(cgImage: cgImage)
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
