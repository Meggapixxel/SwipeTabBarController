//
//  NetworkRequest.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 31.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

// https://api.github.com/repos/apple/swift/commits?per_page=100
// https://api.github.com/repos/XXXXX/YYYYY/commits?per_page=100
// SCHEME|-----HOST------|----------PATH----------|----QUERY----


// MARK: - P_Request
protocol P_NetworkRequest {
    
    var scheme: String { get }
    var host: String { get }
    var path: P_NetworkRequestPath { get }
    var body: NetworkRequestBodyParameters { get }
    var method: NetworkRequestMethod { get }
    var query: NetworkRequestQueryParameters? { get }
    
}
extension P_NetworkRequest {
    
    func makeUrl() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path.value
        components.queryItems = query?.compactMap { URLQueryItem(name: $0, value: $1?.description) }
        return components.url
    }
    
}


// MARK: - P_Request implementation
final class Request<PATH: P_NetworkRequestPath>: P_NetworkRequest {
    
    let scheme: String
    let host: String
    let method: NetworkRequestMethod
    let path: P_NetworkRequestPath
    let query: NetworkRequestQueryParameters?
    let body: NetworkRequestBodyParameters

    init(
        scheme: String = "https",
        host: String,
        method: NetworkRequestMethod,
        path: PATH,
        query: NetworkRequestQueryParameters?,
        body: NetworkRequestBodyParameters = .none
    ) {
        self.scheme = scheme
        self.host = host
        self.method = method
        self.path = path
        self.query = query
        self.body = body
    }
    
}
