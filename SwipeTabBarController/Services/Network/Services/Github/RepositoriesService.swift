//
//  GithubRepositoriesService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

struct GithubRespositoryPaths: P_NetworkRequestPath {
    
    let value: String
    
    static func repositories() -> GithubRespositoryPaths {
        .init(value: "/repositories")
    }
    
    static func repositories(user: String) -> GithubRespositoryPaths {
        .init(value: .init(format: "/users/%@/repos", user))
    }
    
    static func searchRepositories() -> GithubRespositoryPaths {
        .init(value: "/search/repositories")
    }
    
}

protocol P_GithubRepositoriesService: P_GithubService {
    
    typealias PATHS = GithubRespositoryPaths
    typealias NO = GithubRepositoryNO
    
    func get(_ completion: @escaping (Result<[NO], NetworkClientError>) -> Void)
    func get(user: String, _ completion: @escaping (Result<[NO], NetworkClientError>) -> Void)
    func search(query: String, _ completion: @escaping (Result<GithubSearchNO<NO>, NetworkClientError>) -> Void)
    
}
private extension P_GithubRepositoriesService {
    
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


class GithubRepositoriesService: P_GithubRepositoriesService {
    
    private let networkClient: P_NetworkClient
    
    init(networkClient: P_NetworkClient) {
        self.networkClient = networkClient
    }
    
    func get(_ completion: @escaping (Result<[NO], NetworkClientError>) -> Void) {
        networkClient.request(
            request: createNetworkRequest(method: .get, path: .repositories())
        ) { (result) in
            switch result {
            case .success(let data):
                let models: [NO]
                do {
                    models = try GithubRepositoriesService.jsonDecoder.decode([NO].self, from: data)
                } catch {
                    return completion(.failure(.some(error)))
                }
                completion(.success(models))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func get(user: String, _ completion: @escaping (Result<[NO], NetworkClientError>) -> Void) {
        networkClient.request(
            request: createNetworkRequest(method: .get, path: .repositories(user: user))
        ) { (result) in
            switch result {
            case .success(let data):
                let models: [NO]
                do {
                    models = try GithubRepositoriesService.jsonDecoder.decode([NO].self, from: data)
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
            request: createNetworkRequest(method: .get, path: .searchRepositories(), query: ["q": query])
        ) { (result) in
            switch result {
            case .success(let data):
                let model: GithubSearchNO<NO>
                do {
                    model = try GithubRepositoriesService.jsonDecoder.decode(GithubSearchNO<NO>.self, from: data)
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
