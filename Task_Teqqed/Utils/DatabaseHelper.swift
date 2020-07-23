//
//  DatabaseHelper.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/21/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import Foundation
import CoreData

enum Entities: String {
    case posts
    case users
    case comments

    var name: String {
        return rawValue.capitalized
    }
}

protocol DatabaseDataProviderType: class {
    func getPosts(forUserId userId: Int?) -> [Post]
    func cachePosts(_ posts: [Post])
    
    func getUser(forUserId userId: Int) -> User?
    func cacheUser(_ user: User)

    func getComments(forPostId postId: Int) -> [Comment]
    func cacheComments(_ comments: [Comment])
}

final class DatabaseDataProvider {
    
}

extension DatabaseDataProvider: DatabaseDataProviderType {

    func getPosts(forUserId userId: Int?) -> [Post] {
        var predicate: NSPredicate?
        if let userId = userId {
            predicate = NSPredicate(format: "userId == %d", userId)
        }
        return DatabaseHelper.instance.get(
            entityName: Entities.posts.name,
            predicate: predicate,
            create: { (entity: Posts) -> Post in
                return Post(
                    id: Int(entity.id),
                    userId: Int(entity.userId),
                    title: entity.title ?? "",
                    body: entity.body ?? "")
        })
    }

    func cachePosts(_ posts: [Post]) {
        DatabaseHelper.instance.cache(
            items: posts,
            entityName: Entities.posts.name,
            cachedEntityForItem: { (entities: [Posts], item: Post) in
                return entities.first { $0.id == item.id }
            },
            updateEntityWithItem: { (postEntity: Posts, post: Post) in
                postEntity.id = Int32(post.id)
                postEntity.userId = Int32(post.userId)
                postEntity.body = post.body
                postEntity.title = post.title
            })
    }
    
    func getUser(forUserId userId: Int) -> User? {
        let users = DatabaseHelper.instance.get(
                   entityName: Entities.users.name,
                   predicate: NSPredicate(format: "id == %d", userId),
                   create: { (entity: Users) -> User in
                       return User(
                           id: Int(entity.id),
                           name: entity.name ?? "",
                           username: entity.username ?? "",
                           email: entity.email ?? "")
        })

        if users.isEmpty {
            return nil
        } else {
            return users.first
        }
    }
    
    func cacheUser(_ user: User) {
        DatabaseHelper.instance.cache(
            items: [user],
            entityName: Entities.users.name,
            cachedEntityForItem: { (entities: [Users], item: User) in
                return entities.first { $0.id == item.id }
            },
            updateEntityWithItem: { (userEntity: Users, user: User) in
                userEntity.id = Int32(user.id)
                userEntity.name = user.name
                userEntity.username = user.username
                userEntity.email = user.email
        })
    }
    
    func cacheComments(_ comments: [Comment]) {
        DatabaseHelper.instance.cache(
           items: comments,
           entityName: Entities.comments.name,
           cachedEntityForItem: { (entities: [Comments], item: Comment) in
               return entities.first { $0.id == item.id }
           },
           updateEntityWithItem: { (commentEntity: Comments, comment: Comment) in
               commentEntity.id = Int32(comment.id)
               commentEntity.postId = Int32(comment.postId)
               commentEntity.name = comment.name
               commentEntity.body = comment.body
               commentEntity.email = comment.email
        })
    }
    
    func getComments(forPostId postId: Int) -> [Comment] {
        return DatabaseHelper.instance.get(
            entityName: Entities.comments.name,
            predicate: NSPredicate(format: "postId == %d", postId),
            create: { (entity: Comments) -> Comment in
                return Comment(
                    postId: Int(entity.postId),
                    id: Int(entity.id),
                    name: entity.name ?? "",
                    email: entity.email ?? "",
                    body: entity.body ?? "")
        })
    }
}


enum DatabaseError: LocalizedError {
    case noBackgroundContext
    case multipleEntitiesFound
}

final class DatabaseHelper {
    
    static let instance = DatabaseHelper()
    
    func get<Type: Identifiable, EntityType: NSManagedObject>(
        entityName: String,
        predicate: NSPredicate? = nil,
        create: @escaping (EntityType) -> Type) -> [Type] {
        
        guard let context = DatabaseHelper.instance.backgroundContext else {
            return []
        }
        
        debugPrint(".. loading entities")
        do {
            let fetchRequest = NSFetchRequest<EntityType>(entityName: entityName)
            fetchRequest.predicate = predicate
            let entities = try context.fetch(fetchRequest)
            debugPrint(".. loading entities OK: \(entities.count)")
            let items: [Type] = entities.map(create)
                .sorted(by: { (left, right) in
                    return left.id < right.id
                })
            return items
        } catch {
            debugPrint("..loading entities")
            return []
        }
    }
    
    func cache<Type, EntityType: NSManagedObject>(
        items: [Type],
        entityName: String,
        cachedEntityForItem: @escaping ([EntityType], Type) -> EntityType?,
        updateEntityWithItem: @escaping (EntityType, Type) -> Void) {
        
        guard let context = backgroundContext else {
            return
        }
        
        context.perform {
            let entities = (try? context.fetch(NSFetchRequest<EntityType>(entityName: entityName))) ?? []
            items.forEach { item in
                let entity = cachedEntityForItem(entities, item) ?? EntityType(context: context)
                updateEntityWithItem(entity, item)
            }
            do {
                try context.save()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let context = backgroundContext {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
    
    // MARK: - Private
    
    private init() {
        self.createPersistentContainer()
    }
    
    private(set) var backgroundContext: NSManagedObjectContext?
    
    private var persistentContainer: NSPersistentContainer?
    
    private func createPersistentContainer() {
        
        let container = NSPersistentContainer(name: "Task_Teqqed")
        container.loadPersistentStores(completionHandler: { [weak self] (_, error) in
            if let error = error as NSError? {
                debugPrint(error)
            } else {
                self?.backgroundContext = container.newBackgroundContext()
            }
        })
        persistentContainer = container
    }
}
