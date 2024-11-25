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
