//
//  SwingSession.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-25.
//
import Foundation
import CoreMotion
import CoreData

struct SwingSession: Identifiable, Codable {
    let id: UUID
    var firebaseUID: String?
    var date: Date
    var rotationData: [[String: Double]] // Encoded CMRotationRate
    var accelerationData: [[String: Double]] // Encoded CMAcceleration

    // Convenience initializer for Motion Data
    init(id: UUID = UUID(), firebaseUID: String? = nil, date: Date, rotationData: [CMRotationRate], accelerationData: [CMAcceleration]) {
        self.id = id
        self.firebaseUID = firebaseUID
        self.date = date
        self.rotationData = rotationData.map { ["x": $0.x, "y": $0.y, "z": $0.z] }
        self.accelerationData = accelerationData.map { ["x": $0.x, "y": $0.y, "z": $0.z] }
    }

    // Convenience initializer for Firebase/CoreData-friendly format
    init(id: UUID, firebaseUID: String?, date: Date, rotationData: [[String: Double]], accelerationData: [[String: Double]]) {
        self.id = id
        self.firebaseUID = firebaseUID
        self.date = date
        self.rotationData = rotationData
        self.accelerationData = accelerationData
    }
}
extension SwingSessionEntity {
    // Convert Core Data entity to Swift model
    func toSwingSession() -> SwingSession {
        let rotationData = (try? JSONSerialization.jsonObject(with: self.rotationData ?? Data(), options: []) as? [[String: Double]]) ?? []
        let accelerationData = (try? JSONSerialization.jsonObject(with: self.accelerationData ?? Data(), options: []) as? [[String: Double]]) ?? []

        return SwingSession(
            id: self.id ?? UUID(),
            firebaseUID: self.firebaseUID,
            date: self.date ?? Date(),
            rotationData: rotationData,
            accelerationData: accelerationData
        )
    }

    // Update Core Data entity from Swift model
    func update(from session: SwingSession) {
        self.id = session.id
        self.firebaseUID = session.firebaseUID
        self.date = session.date
        self.rotationData = try? JSONSerialization.data(withJSONObject: session.rotationData, options: [])
        self.accelerationData = try? JSONSerialization.data(withJSONObject: session.accelerationData, options: [])
    }
}
/// Mock sessions used for previews and testing
extension SwingSession {
    // Mock data for testing and previews
    static var MOCK_SESSION: SwingSession {
        let mockRotationData: [CMRotationRate] = [
            CMRotationRate(x: 1.2, y: 0.5, z: -0.8),
            CMRotationRate(x: -0.3, y: 1.1, z: 0.0),
            CMRotationRate(x: 0.7, y: -0.4, z: 0.6)
        ]

        let mockAccelerationData: [CMAcceleration] = [
            CMAcceleration(x: 0.1, y: -0.2, z: 0.3),
            CMAcceleration(x: 0.4, y: 0.0, z: -0.1),
            CMAcceleration(x: -0.3, y: 0.2, z: 0.1)
        ]

        return SwingSession(
            id: UUID(),
            firebaseUID: "mockFirebaseUID",
            date: Date(),
            rotationData: mockRotationData,
            accelerationData: mockAccelerationData
        )
    }
}
extension SwingSessionEntity {
    static func mock(context: NSManagedObjectContext) -> SwingSessionEntity {
        let entity = SwingSessionEntity(context: context)
        entity.id = UUID()
        entity.firebaseUID = "mockFirebaseUID"
        entity.date = Date()
        entity.rotationData = try? JSONSerialization.data(withJSONObject: [
            ["x": 1.2, "y": 0.5, "z": -0.8],
            ["x": -0.3, "y": 1.1, "z": 0.0],
            ["x": 0.7, "y": -0.4, "z": 0.6]
        ])
        entity.accelerationData = try? JSONSerialization.data(withJSONObject: [
            ["x": 0.1, "y": -0.2, "z": 0.3],
            ["x": 0.4, "y": 0.0, "z": -0.1],
            ["x": -0.3, "y": 0.2, "z": 0.1]
        ])
        return entity
    }
}
