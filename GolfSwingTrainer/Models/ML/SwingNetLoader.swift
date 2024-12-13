//
//  SwingNetLoader.swift
//  GolfSwingTrainer
//
//  Created by David on 2024-12-05.
//

import CoreML

func predictWithSwingNet(inputs: [Float32]) -> [Float32]? {
    // Load the model
    guard let model = try? SwingNet(configuration: .init()) else {
        print("Failed to load SwingNet model")
        return nil
    }
    
    // Create the model's input
    guard let inputArray = try? MLMultiArray(shape: [64, 3, 224, 224], dataType: .float32) else {
        print("Failed to create MLMultiArray")
        return nil
    }
    
    // Populate MLMultiArray with input data
    for (index, value) in inputs.enumerated() {
        inputArray[index] = NSNumber(value: value)
    }
    
    do {
        // Make a prediction
        let input = SwingNetInput(x: inputArray)
        let output = try model.prediction(input: input)
        
        // Convert MLMultiArray to [Float32]
        if let outputArray = output.var_874 as? MLMultiArray {
            var result: [Float32] = []
            for i in 0..<outputArray.count {
                result.append(Float32(truncating: outputArray[i]))
            }
            return result
        } else {
            print("Failed to cast output to MLMultiArray")
            return nil
        }
        
    } catch {
        print("Failed to make prediction: \(error)")
        return nil
    }
}

