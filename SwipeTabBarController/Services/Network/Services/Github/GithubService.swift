//
//  GithubService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 30.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_GithubService {
    
}

extension P_GithubService {
    
    var scheme: String { "https" }
    var host: String { "api.github.com" }
    
    func createNetworkRequest<PATH: P_NetworkRequestPath>(
        method: NetworkRequestMethod,
        path: PATH,
        query: NetworkRequestQueryParameters? = nil,
        body: NetworkRequestBodyParameters = .none
    ) -> Request<PATH> {
        Request(
            scheme: scheme,
            host: host,
            method: method,
            path: path,
            query: query,
            body: body
        )
    }
    
}


