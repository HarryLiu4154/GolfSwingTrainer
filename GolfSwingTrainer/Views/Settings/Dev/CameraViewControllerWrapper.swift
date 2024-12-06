//
//  CameraViewControllerWrapper.swift
//  GolfSwingTrainer
//
//  Created by David on 2024-12-05.
//
import SwiftUI

struct CameraViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
