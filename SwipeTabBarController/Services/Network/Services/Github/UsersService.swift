//
//  GithubUsersService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

struct GithubUsersPaths: P_NetworkRequestPath {
    
    let value: String
    
    static func users() -> GithubUsersPaths {
        .init(value: "/users")
    }
    
    static func searchUsers() -> GithubUsersPaths {
        .init(value: "/search/users")
    }
    
}

protocol P_GithubUsersService: P_GithubService {
    
    typealias PATHS = GithubUsersPaths
    typealias NO = GithubUserNO
    
    func get(_ completion: @escaping (Result<[NO], NetworkClientError>) -> Void)
    func search(query: String, _ completion: @escaping (Result<GithubSearchNO<NO>, NetworkClientError>) -> Void)
    
}
private extension P_GithubUsersService {
    
    func createNetworkRequest(
        method: NetworkRequestMethod,
        path: PATHS,
        query: NetworkRequestQueryParameters? = nil,
        body: NetworkRequestBodyParameters = .none
    ) -> Request<PATHS> {
        (self as P_GithubService).createNetworkRequest(method: method, path: path, query: query, body: body)
    }
    
    static var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
}


final class GithubUsersService: P_GithubUsersService {
    
    private let networkClient: P_NetworkClient
    
    init(networkClient: P_NetworkClient) {
        self.networkClient = networkClient
    }
    
    func get(_ completion: @escaping (Result<[NO], NetworkClientError>) -> Void) {
        networkClient.request(
            request: createNetworkRequest(method: .get, path: .users())
        ) { (result) in
            switch result {
            case .success(let data):
                let models: [NO]
                do {
                    models = try GithubUsersService.jsonDecoder.decode([NO].self, from: data)
                } catch {
                    return completion(.failure(.some(error)))
                }
                completion(.success(models))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func search(query: String, _ completion: @escaping (Result<GithubSearchNO<NO>, NetworkClientError>) -> Void) {
        networkClient.request(
            request: createNetworkRequest(method: .get, path: .searchUsers(), query: ["q": query])
        ) { (result) in
            switch result {
            case .success(let data):
                let model: GithubSearchNO<NO>
                do {
                    model = try GithubUsersService.jsonDecoder.decode(GithubSearchNO<NO>.self, from: data)
                } catch {
                    return completion(.failure(.some(error)))
                }
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
