//
//  CoreDataService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 25.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import CoreData

// 'Entity' checkbox 'Optional' for attribute - determines whether the objects that Core Data stores are required to have a value or not.

class CoreDataService {
    
    var container: NSPersistentContainer!
    
    init() {
        container = NSPersistentContainer(name: "DatabaseV1")

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Unresolved error \(error)")
            } else {
//                if an object exists in its data store with message A,
//                and an object with the same unique constraint exists in memory with message B,
//                the in-memory version "trumps" (overwrites) the data store version.
                self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            }
        }
    }
    
    func saveContext() {
        guard container.viewContext.hasChanges else { return }
        do {
            try container.viewContext.save()
        } catch {
            print("An error occurred while saving: \(error)")
        }
    }
    
}
