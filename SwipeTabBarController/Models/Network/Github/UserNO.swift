//
//  GithubUserNO.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

struct GithubUserNO: Decodable {
    
    let id: Int
    let login: String
    let avatarUrl: String // "avatar_url": "https://avatars0.githubusercontent.com/u/1?v=4"
    
}
