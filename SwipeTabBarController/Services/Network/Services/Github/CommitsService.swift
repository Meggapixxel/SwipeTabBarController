//
//  CommitsService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

struct GithubCommitsPaths: P_NetworkRequestPath {
    
    let value: String
    
    static func commits(user: String, repository: String) -> GithubCommitsPaths {
        .init(value: .init(format: "/repos/%@/%@/commits", user, repository))
    }
    
}

protocol P_GithubCommitsService: P_GithubService {
    
    typealias PATHS = GithubCommitsPaths
    typealias NO = GithubCommitNO
    
    func get(user: String, repository: String, perPage: Int, sinceDate: Date?, _ completion: @escaping (Result<[NO], NetworkClientError>) -> Void)
    
}
extension P_GithubCommitsService {
    
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
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    func get(user: String, repository: String, perPage: Int = 100, sinceDate: Date? = nil, _ completion: @escaping (Result<[NO], NetworkClientError>) -> Void) {
        get(user: user, repository: repository, perPage: perPage, sinceDate: sinceDate, completion)
    }
    
}

final class GithubCommitsService: P_GithubCommitsService {
    
    private let networkClient: P_NetworkClient
    
    init(networkClient: P_NetworkClient) {
        self.networkClient = networkClient
    }
    
    func get(user: String, repository: String, perPage: Int, sinceDate: Date?, _ completion: @escaping (Result<[NO], NetworkClientError>) -> Void) {
        networkClient.request(
            request: createNetworkRequest(
                method: .get,
                path: .commits(user: user, repository: repository),
                query: [
                    "per_page": perPage,
                    "since": sinceDate?.toISO8601
                ]
            )
        ) { (result) in
            switch result {
            case .success(let data):
                let apiCommits: [GithubCommitNO]
                do {
                    apiCommits = try GithubCommitsService.jsonDecoder.decode([GithubCommitNO].self, from: data)
                } catch {
                    return completion(.failure(.some(error)))
                }
                completion(.success(apiCommits))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

private extension Date {
    
    var toISO8601: String { ISO8601DateFormatter().string(from: self) }
    
}
