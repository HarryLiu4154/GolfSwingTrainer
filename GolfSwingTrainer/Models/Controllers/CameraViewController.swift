//
//  CameraViewController.swift
//  GolfSwingTrainer
//
//  Created by David on 2024-12-05.
//
import UIKit
import AVFoundation
import CoreML
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var model: SwingNet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        loadModel()
    }
    
    // Setup the camera
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to access the camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }
        
        // Setup video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Add preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // Start the session
        captureSession.startRunning()
    }
    
    // Load the SwingNet model
    func loadModel() {
        do {
            model = try SwingNet(configuration: .init())
        } catch {
            print("Failed to load SwingNet model: \(error)")
        }
    }
    
    // Capture video frames
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        processFrame(pixelBuffer: pixelBuffer)
    }
    
    // Process a single frame
    func processFrame(pixelBuffer: CVPixelBuffer) {
        guard let inputArray = preprocessFrame(pixelBuffer: pixelBuffer) else {
            print("Failed to preprocess frame")
            return
        }
        predictWithSwingNet(input: inputArray)
    }
    
    // Preprocess the frame for model input
    func preprocessFrame(pixelBuffer: CVPixelBuffer) -> MLMultiArray? {
        let batchSize = 1
        let channels = 3
        let width = 224
        let height = 224
        
        guard let inputArray = try? MLMultiArray(shape: [batchSize, channels, height, width] as [NSNumber], dataType: .float32) else {
            print("Failed to create MLMultiArray")
            return nil
        }
        
        // Resize the pixel buffer
        guard let resizedImage = UIImage(pixelBuffer: pixelBuffer)?.resize(to: CGSize(width: width, height: height)),
              let resizedPixelBuffer = resizedImage.pixelBuffer() else {
            print("Failed to resize frame")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resizedPixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(resizedPixelBuffer, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(resizedPixelBuffer) else {
            print("Failed to get base address")
            return nil
        }
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(resizedPixelBuffer)
        let pixelPointer = baseAddress.assumingMemoryBound(to: UInt8.self)
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * bytesPerRow + x * channels
                let red = Float(pixelPointer[offset]) / 255.0
                let green = Float(pixelPointer[offset + 1]) / 255.0
                let blue = Float(pixelPointer[offset + 2]) / 255.0
                
                inputArray[[0, 0, y, x] as [NSNumber]] = NSNumber(value: red)
                inputArray[[0, 1, y, x] as [NSNumber]] = NSNumber(value: green)
                inputArray[[0, 2, y, x] as [NSNumber]] = NSNumber(value: blue)
            }
        }
        
        return inputArray
    }
    
    // Make a prediction using SwingNet
    func predictWithSwingNet(input: MLMultiArray) {
        guard let model = model else {
            print("Model is not loaded")
            return
        }
        
        do {
            let predictionInput = SwingNetInput(x: input)
            let output = try model.prediction(input: predictionInput)
            handlePrediction(output: output)
        } catch {
            print("Failed to make prediction: \(error)")
        }
    }
    
    // Handle the model's prediction
    func handlePrediction(output: SwingNetOutput) {
        DispatchQueue.main.async {
            print("Prediction result: \(output.var_874)") // Replace `var_874` with the actual output variable's name
            // Perform additional actions based on the prediction
        }
    }
}

// UIImage extension for resizing
extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    convenience init?(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height),
                                         kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let cgContext = context else { return nil }
        
        cgContext.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        return buffer
    }
}
