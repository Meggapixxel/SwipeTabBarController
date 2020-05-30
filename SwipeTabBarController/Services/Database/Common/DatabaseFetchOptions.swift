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
    
    case fetchLimit(Int)
    case fetchOffset(Int)
    case fetchBatchSize(Int)
    
    static var first: DatabaseFetchOption { .fetchLimit(1) }
    
}

extension DatabaseFetchOption: Hashable {
    
    private var developerHashValue: Int {
        switch self {
        case .fetchLimit: return 0
        case .fetchOffset: return 1
        case .fetchBatchSize: return 2
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
        case .fetchLimit(let value):
            fetchRequest.fetchLimit = value
        case .fetchOffset(let value):
            fetchRequest.fetchOffset = value
        case .fetchBatchSize(let value):
            fetchRequest.fetchBatchSize = value
        }
    }
    
}

extension DatabaseFetchOptions {
    
    func set<MO: NSManagedObject>(in fetchRequest: NSFetchRequest<MO>) {
        forEach { $0.set(in: fetchRequest) }
    }
    
}
