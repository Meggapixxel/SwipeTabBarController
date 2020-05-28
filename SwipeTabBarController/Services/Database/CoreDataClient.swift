//
//  CoreDataService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 25.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import CoreData

// 'Entity' checkbox 'Optional' for attribute - determines whether the objects that Core Data stores are required to have a value or not.

protocol P_CoreDataClient {
    
    func saveContext() throws
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) throws -> [T]
    
    func insertAndSave<T: NSManagedObject>(model: T) throws
    func insert<T: NSManagedObject>(model: T)
    func insertIfNeeded<T: NSManagedObject>(model: T)
    
    func delete<T: NSManagedObject>(model: T)
    func deleteAndSave<T: NSManagedObject>(model: T) throws
    
    func entityDescription<T: NSManagedObject>(type: T.Type) -> NSEntityDescription
    func model<T: NSManagedObject>(type: T.Type) -> T
    
}

extension P_CoreDataClient {
    
    func insertAndSave<T: NSManagedObject>(models: [T]) throws {
        insertIfNeeded(models: models)
        try saveContext()
    }
    
    func insert<T: NSManagedObject>(models: [T]) {
        models.forEach { insert(model: $0) }
    }
    
    func insertIfNeeded<T: NSManagedObject>(models: [T]) {
        models.forEach { insertIfNeeded(model: $0) }
    }
    
}

class CoreDataClient: P_CoreDataClient {
    
    private let container = NSPersistentContainer(name: "DatabaseV1")
    
    init() {
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            } else {
                // if an object exists in its data store with message A,
                // and an object with the same unique constraint exists in memory with message B,
                // the in-memory version "trumps" (overwrites) the data store version.
                self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
    }
    
    func saveContext() throws {
        guard container.viewContext.hasChanges else { return }
        try container.viewContext.save()
    }
    
}

extension CoreDataClient {
    
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) throws -> [T] {
        try container.viewContext.fetch(request)
    }
    
}

extension CoreDataClient {
    
    func insertAndSave<T: NSManagedObject>(model: T) throws {
        insert(model: model)
        try saveContext()
    }
    
    func insert<T: NSManagedObject>(model: T) {
        container.viewContext.insert(model)
    }
    
    func insertIfNeeded<T: NSManagedObject>(model: T) {
        guard !container.viewContext.insertedObjects.contains(model) else { return }
        container.viewContext.insert(model)
    }
    
}

extension CoreDataClient {
    
    func delete<T: NSManagedObject>(model: T) {
        container.viewContext.delete(model)
    }
    
    func deleteAndSave<T: NSManagedObject>(model: T) throws {
        delete(model: model)
        try saveContext()
    }
    
}

extension CoreDataClient {

    func entityDescription<T: NSManagedObject>(type: T.Type) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: String(describing: type), in: container.viewContext)!
    }
    
    func model<T: NSManagedObject>(type: T.Type) -> T {
        let entity = entityDescription(type: type)
        let model = T(entity: entity, insertInto: nil)
        return model
    }
    
}
