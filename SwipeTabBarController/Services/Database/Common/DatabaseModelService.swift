//
//  DatabaseModelService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 29.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol DatabaseModelService {
    init(client: P_CoreDataClient, fetchQueue: DispatchQueue, completionQueue: DispatchQueue)
}
