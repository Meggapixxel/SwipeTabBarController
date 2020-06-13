//
//  GithubSearchNO.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 14.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

struct GithubSearchNO<T: Decodable>: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [T]
}
