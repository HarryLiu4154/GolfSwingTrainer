//
//  CoreDataService.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-24.
//

import Foundation
import CoreData

class CoreDataService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    //MARK: - User Services

    func fetchUser(by uid: String) -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)
        request.fetchLimit = 1

        if let userEntity = try? context.fetch(request).first {
            return userEntity.toUser()
        }
        return nil
    }

    func saveUser(_ user: User) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", user.uid)

        if let userEntity = try? context.fetch(request).first {
            userEntity.update(from: user, context: context)
        } else {
            let newUserEntity = UserEntity(context: context)
            newUserEntity.update(from: user, context: context)
        }
    }

    func deleteUser(_ user: User) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", user.uid)

        if let userEntity = try? context.fetch(request).first {
            context.delete(userEntity)
            try? context.save()
        }
    }
}
//MARK: - Swing Session Services
extension CoreDataService {
    func fetchSwingSessions() -> [SwingSession] {
        let request: NSFetchRequest<SwingSessionEntity> = SwingSessionEntity.fetchRequest()
        guard let entities = try? context.fetch(request) else { return [] }
        return entities.map { $0.toSwingSession() }
    }

    func saveSwingSession(_ session: SwingSession) {
        let request: NSFetchRequest<SwingSessionEntity> = SwingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        let entity = (try? context.fetch(request).first) ?? SwingSessionEntity(context: context)
        entity.update(from: session)
        try? context.save()
    }

    func deleteSwingSession(_ session: SwingSession) {
        let request: NSFetchRequest<SwingSessionEntity> = SwingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            try? context.save()
        }
    }
}
//MARK: - TBD
