//
//  RecordingSessionSelectorViewModel.swift
//  GolfSwingTrainer
//
//  Created by Kevin on 2024-12-05.
//

import Foundation

class RecordingSessionSelectorViewModel: ObservableObject {
    private let coreDataService: CoreDataService
    
    @Published var recordingSessions: [RecordingSession]
    
    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
        self.recordingSessions = coreDataService.fetchRecordingSessions()
    }
    
    func update() {
        self.recordingSessions = self.coreDataService.fetchRecordingSessions()
    }
}
