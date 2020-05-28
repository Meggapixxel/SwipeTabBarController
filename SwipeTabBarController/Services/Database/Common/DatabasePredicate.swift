//
//  DatabasePredicate.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 28.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

// https://nshipster.com/nspredicate/

import CoreData

class DatabasePredicate<Element: NSManagedObject> {

    private(set) var predicate: NSPredicate
    
    init(predicate: NSPredicate) {
        self.predicate = predicate
    }
    
}

extension DatabasePredicate {
    static func equals<T: Equatable & CVarArg>(keyPath: KeyPath<Element, T>, value: T) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) == %@", value))
    }
    static func contains<T: Equatable & CVarArg>(keyPath: KeyPath<Element, T>, value: T) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) CONTAINS %@", value))
    }
}

extension DatabasePredicate {
    
    static func greater<T: Comparable & CVarArg>(keyPath: KeyPath<Element, T>, value: T) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) > %@", value))
    }
    static func greaterOrEqual<T: Comparable & CVarArg>(keyPath: KeyPath<Element, T>, value: T) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) >= %@", value))
    }
    static func less<T: Comparable & CVarArg>(keyPath: KeyPath<Element, T>, value: T) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) < %@", value))
    }
    static func lessOrEqual<T: Comparable & CVarArg>(keyPath: KeyPath<Element, T>, value: T) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) <= %@", value))
    }
    
}

extension DatabasePredicate {
    
    enum StringCompare {
        case caseInsensitive, caseSensitive
        var string: String { self == .caseInsensitive ? "[c]" : "" }
    }
    
    static func contains(keyPath: KeyPath<Element, String>, value: String, option: StringCompare) -> DatabasePredicate {
        let predicate = NSPredicate(format: "\(keyPath.string) CONTAINS\(option.string) '\(value)'")
        return .init(predicate: predicate)
    }
    static func beginsWith(keyPath: KeyPath<Element, String>, value: String, option: StringCompare) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) BEGINSWITH\(option.string) '\(value)'"))
    }
    
}

extension DatabasePredicate {
    static func `in`<T: Equatable & CVarArg>(keyPath: KeyPath<Element, T>, values: [T]) -> DatabasePredicate {
        .init(predicate: .init(format: "\(keyPath.string) IN %@", values))
    }
}

extension DatabasePredicate {
    
    func and(_ databasePredicate: DatabasePredicate) -> DatabasePredicate {
        predicate = NSCompoundPredicate(type: .and, subpredicates: [self.predicate, databasePredicate.predicate])
        return self
    }
    
    func or(_ databasePredicate: DatabasePredicate) -> DatabasePredicate {
        predicate = NSCompoundPredicate(type: .or, subpredicates: [self.predicate, databasePredicate.predicate])
        return self
    }
    
    func not(_ databasePredicate: DatabasePredicate) -> DatabasePredicate {
        predicate = NSCompoundPredicate(type: .not, subpredicates: [self.predicate, databasePredicate.predicate])
        return self
    }
    
    static func not(_ databasePredicate: DatabasePredicate) -> DatabasePredicate {
        .init(predicate: NSCompoundPredicate(type: .not, subpredicates: [databasePredicate.predicate]))
    }
    
}
