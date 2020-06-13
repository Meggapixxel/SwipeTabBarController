//
//  DatabaseFetchOptions.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 30.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

typealias DatabaseFetchOptions = Set<DatabaseFetchOption>
enum DatabaseFetchOption {
    
    case limit(Int)
    case offset(Int)
    case batchSize(Int)
    
    static var first: DatabaseFetchOption { .limit(1) }
    
}

extension DatabaseFetchOption: Hashable {
    
    private var developerHashValue: Int {
        switch self {
        case .limit: return 0
        case .offset: return 1
        case .batchSize: return 2
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(developerHashValue)
    }
    
}

// MARK: - DatabaseFetchOption+CoreData
import CoreData

extension DatabaseFetchOption {
    
    func set<MO: NSManagedObject>(in fetchRequest: NSFetchRequest<MO>) {
        switch self {
        case .limit(let value):
            fetchRequest.fetchLimit = value
        case .offset(let value):
            fetchRequest.fetchOffset = value
        case .batchSize(let value):
            fetchRequest.fetchBatchSize = value
        }
    }
    
}

extension DatabaseFetchOptions {
    
    func set<MO: NSManagedObject>(in fetchRequest: NSFetchRequest<MO>) {
        forEach { $0.set(in: fetchRequest) }
    }
    
}
