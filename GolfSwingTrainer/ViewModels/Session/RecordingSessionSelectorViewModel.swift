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
        self.recordingSessions = self.coreDataService.fetchRecordingSessions().sorted {
            return $0.date > $1.date
        }
    }
    
    func update() {
        self.recordingSessions = self.coreDataService.fetchRecordingSessions().sorted {
            return $0.date > $1.date
        }
    }
}
