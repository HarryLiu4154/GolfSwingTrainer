//
//  RecordingSessionSelectorView.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-05.
//

import SwiftUI

struct RecordingSessionSelectorView: View {
    @EnvironmentObject var viewModel: RecordingSessionSelectorViewModel
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.recordingSessions) { recordingSession in
                NavigationLink{
                    PlayerView(viewModel: PlayerViewModel(recordingSession: recordingSession))
                }label:{
                    RecordingSessionComponentView(recordingSession: recordingSession)
                }
            }
        }
        .refreshable {
            viewModel.update()
        }
    }
}

#Preview {
    RecordingSessionSelectorView()
}
