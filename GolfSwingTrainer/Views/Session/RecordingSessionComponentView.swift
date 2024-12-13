//
//  RecordingSessionComponentView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-05.
//

import SwiftUI

struct RecordingSessionComponentView: View {
    let recordingSession: RecordingSession
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "waveform")
                Spacer()
                Text(recordingSession.date.formatted())
            }
        }
        .padding()
    }
}

#Preview {
    RecordingSessionComponentView(recordingSession: RecordingSession(userUID: nil, date: Date(), videoURL: URL.documentsDirectory.appending(path: "Session.mov"), timestampData: [0,1], speedData: [1,0]))
}
