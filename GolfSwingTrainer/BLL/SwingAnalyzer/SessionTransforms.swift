//
//  SessionTransforms.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-04.
//

import ARKit

class SessionTransforms {
    private var prevWorldTransform: simd_float4x4
    private var prevRightHandTransform: simd_float4x4
    private var prevLeftHandTransform: simd_float4x4
    private var prevTimestamp: TimeInterval
    
    private var prevRightHandWorldPos: simd_float3 {
        return SessionTransforms.calcWorldPos(worldTransform: prevWorldTransform, localTransform: prevRightHandTransform)
    }
    private var prevLeftHandWorldPos: simd_float3 {
        return SessionTransforms.calcWorldPos(worldTransform: prevWorldTransform, localTransform: prevLeftHandTransform)
    }
    
    init(initialWorldTransform: simd_float4x4, initialRightHandTransform: simd_float4x4, initialLeftHandTransform: simd_float4x4, initialTimestamp: TimeInterval) {
        prevWorldTransform = initialWorldTransform
        prevRightHandTransform = initialRightHandTransform
        prevLeftHandTransform = initialLeftHandTransform
        prevTimestamp = initialTimestamp
    }
    
    private static func calcWorldPos(worldTransform: simd_float4x4, localTransform: simd_float4x4) -> simd_float3 {
        return simd_make_float3(worldTransform * localTransform.columns.3)
    }
    
    func calculateUpdateSpeed(newWorldTransform: simd_float4x4, newRightHandTransform: simd_float4x4, newLeftHandTransform: simd_float4x4, newTimestamp: TimeInterval) -> Double {
        let timeDelta = newTimestamp - prevTimestamp
        let newRightHandWorldPos = SessionTransforms.calcWorldPos(worldTransform: newWorldTransform, localTransform: newRightHandTransform)
        let newLeftHandWorldPos = SessionTransforms.calcWorldPos(worldTransform: newWorldTransform, localTransform: newLeftHandTransform)
        let rightHandSpeed = Double(simd_precise_distance(prevRightHandWorldPos, newRightHandWorldPos)) / timeDelta
        let leftHandSpeed = Double(simd_precise_distance(prevLeftHandWorldPos, newLeftHandWorldPos)) / timeDelta
        let avgSpeed = (rightHandSpeed + leftHandSpeed) / 2.0


        prevWorldTransform = newWorldTransform
        prevRightHandTransform = newRightHandTransform
        prevLeftHandTransform = newLeftHandTransform
        prevTimestamp = newTimestamp
        
        print("\(avgSpeed) m/s")
        if avgSpeed.isFinite {
            return avgSpeed
        } else {
            print("non finite speed, resetting to 0")
            return 0.0
        }
    }
}
