//
//  MotionData.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-10-18.
//

import CoreMotion
import SwiftUI
import UIKit
import WatchConnectivity

class MotionData: ObservableObject {
    @Published var motion: CMMotionManager?
    
    init() {
        motion = CMMotionManager()
    }
}
