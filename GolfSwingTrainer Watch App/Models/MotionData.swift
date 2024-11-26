//
//  MotionData.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation

struct MotionData: Codable {
    let rotationRate: [String: Double] // x, y, z
    let userAcceleration: [String: Double] // x, y, z
    let timestamp: TimeInterval // Timestamp of the motion data
}
