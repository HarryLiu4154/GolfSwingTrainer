//
//  RecordingSession.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-04.
//

import CoreMotion
import CoreData

struct RecordingSession: Identifiable {
    let id: UUID
    var userUID: String?
    var date: Date
    var videoURL: URL?
    var timestampData: [TimeInterval]
    var speedData: [Double]
    
    init(id: UUID = UUID(), userUID: String?, date: Date, videoURL: URL?, timestampData: [TimeInterval], speedData: [Double]) {
        self.id = id
        self.userUID = userUID
        self.date = date
        self.videoURL = videoURL
        self.timestampData = timestampData
        self.speedData = speedData
    }
}

extension RecordingSessionEntity {
    // Convert Core Data entity to Swift model
    func toRecordingSession() -> RecordingSession {
        let timestampData = (try? JSONSerialization.jsonObject(with: self.timestampData ?? Data() , options: []) as? [TimeInterval]) ?? []
        let speedData = (try? JSONSerialization.jsonObject(with: self.speedData ?? Data(), options: []) as? [Double]) ?? []
        
        return RecordingSession(
            id: self.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            userUID: self.userUID,
            date: self.date ?? Date(timeIntervalSince1970: 0),
            videoURL: self.videoURL,
            timestampData: timestampData,
            speedData: speedData
        )
    }
    
    // Update Core Data entity from Swift model
    func update(from session: RecordingSession) {
        self.id = session.id
        self.userUID = session.userUID
        self.date = session.date
        self.videoURL = session.videoURL
        self.timestampData = try? JSONSerialization.data(withJSONObject: session.timestampData, options: [])
        self.speedData = try? JSONSerialization.data(withJSONObject: session.speedData, options: [])
    }
}
