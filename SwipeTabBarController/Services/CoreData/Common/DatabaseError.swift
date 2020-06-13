//
//  DatabaseError.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

enum DatabaseError: Error {
    case some(Error), notExist
}
