//
//  DatabaseSort.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 28.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import CoreData

enum DatabaseSort<Element: NSManagedObject, T: Comparable> {
    
    case asc(KeyPath<Element, T>)
    case desc(KeyPath<Element, T>)
    
    var key: String {
        switch self {
        case .asc(let keyPath), .desc(let keyPath):
            return keyPath.string
        }
    }
    
    var isAscending: Bool {
        switch self {
        case .asc: return true
        case .desc: return false
        }
    }
    
    var isDescending: Bool {
        switch self {
        case .asc: return false
        case .desc: return true
        }
    }
    
}
