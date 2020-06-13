//
//  NSManagedObject+KeyPath.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 28.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import CoreData

extension KeyPath where Root: NSManagedObject {
    
    var string: String { NSExpression(forKeyPath: self).keyPath }
    
}
