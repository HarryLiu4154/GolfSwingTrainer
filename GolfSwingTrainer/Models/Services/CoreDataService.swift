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

    // MARK: - User Services
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
// MARK: - Account Services
extension CoreDataService {
    func fetchAccount(by id: UUID) -> Account? {
        let request: NSFetchRequest<AccountEntity> = AccountEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let accountEntity = try? context.fetch(request).first {
            return accountEntity.toAccount()
        }
        return nil
    }

    func saveAccount(_ account: Account) {
        let request: NSFetchRequest<AccountEntity> = AccountEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", account.id as CVarArg)

        let accountEntity = (try? context.fetch(request).first) ?? AccountEntity(context: context)
        accountEntity.update(from: account, context: context)
    }

    func deleteAccount(by id: UUID) {
        let request: NSFetchRequest<AccountEntity> = AccountEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        if let accountEntity = try? context.fetch(request).first {
            context.delete(accountEntity)
           try? context.save()
        }
    }
  
    //MARK: - Recording Session Services
    func fetchRecordingSessions() -> [RecordingSession] {
        let request = RecordingSessionEntity.fetchRequest()
        guard let entities = try? context.fetch(request) else { return [] }
        return entities.map { $0.toRecordingSession() }
    }
    
    func saveRecordingSession(_ session: RecordingSession) {
        let request = RecordingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        let entity = (try? context.fetch(request).first) ?? RecordingSessionEntity(context: context)
        entity.update(from: session)
        try? context.save()
    }
    
    func deleteRecordingSession(_ session: RecordingSession) {
        let request = RecordingSessionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", session.id as CVarArg)
        
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            try? context.save()
        }
    }
}
