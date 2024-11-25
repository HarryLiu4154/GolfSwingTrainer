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

    // MARK: - Fetch User by UID
    func fetchUser(by uid: String) -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)
        request.fetchLimit = 1

        if let userEntity = try? context.fetch(request).first {
            return userEntity.toUser()
        }
        return nil
    }

    // MARK: - Fetch Any User (Fallback)
    func fetchAnyUser() -> User? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.fetchLimit = 1

        if let userEntity = try? context.fetch(request).first {
            return userEntity.toUser()
        }
        return nil
    }

    // MARK: - Save or Update User
    func saveUser(_ user: User) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", user.uid)

        if let userEntity = try? context.fetch(request).first {
            userEntity.update(from: user, context: context)
        } else {
            let newUserEntity = UserEntity(context: context)
            newUserEntity.update(from: user, context: context)
        }

        do {
            try context.save()
            print("CoreDataService: Successfully saved user with UID \(user.uid).")
        } catch {
            print("CoreDataService: Failed to save user: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete User by UID
    func deleteUser(by uid: String) {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)

        if let userEntity = try? context.fetch(request).first {
            context.delete(userEntity)
            do {
                try context.save()
                print("CoreDataService: Successfully deleted user with UID \(uid).")
            } catch {
                print("CoreDataService: Failed to delete user: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delete User by User Object
    func deleteUser(_ user: User) {
        deleteUser(by: user.uid)
    }
}
