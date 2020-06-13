//
//  P_DatabaseModel.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 30.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import CoreData

public protocol P_DatabaseModel: NSManagedObject {
    
    static func createFetchRequest() -> NSFetchRequest<Self>
    
}

public extension P_DatabaseModel {
    
    static func createFetchRequest() -> NSFetchRequest<Self> {
        NSFetchRequest<Self>(entityName: String(describing: Self.self))
    }
    
}
