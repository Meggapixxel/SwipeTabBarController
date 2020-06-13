//
//  GithubService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 30.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_NetworkCommitService {
    
    typealias NO = CommitNO
    
    func fetchCommits(perPage: Int, sinceDate: Date?, _ completion: @escaping (Result<[NO], NetworkClientError>) -> Void)
    
}
extension P_NetworkCommitService {
    func fetchCommits(perPage: Int = 100, sinceDate: Date? = nil, _ completion: @escaping (Result<[NO], NetworkClientError>) -> Void) {
        fetchCommits(perPage: perPage, sinceDate: sinceDate, completion)
    }
}


private struct GithubPaths: P_NetworkRequestPath {
    
    let value: String
    
    static func commits(author: String, repository: String) -> GithubPaths {
        .init(value: .init(format: "/repos/%@/%@/commits", author, repository))
    }
    
}

extension Date {
    
    var toISO8601: String { ISO8601DateFormatter().string(from: self) }
    
}

final class GithubService: P_NetworkCommitService {
    
    private typealias REQUEST = Request<GithubPaths>
    
    private let networkClient: P_NetworkClient
    private let scheme: String = "https"
    private let host: String = "api.github.com"
    
    init(networkClient: P_NetworkClient) {
        self.networkClient = networkClient
    }
    
    func fetchCommits(perPage: Int, sinceDate: Date?, _ completion: @escaping (Result<[CommitNO], NetworkClientError>) -> Void) {
        networkClient.request(
            request: REQUEST(
                scheme: scheme,
                host: host,
                method: .get,
                path: .commits(author: "apple", repository: "swift"),
                query: [
                    "per_page": perPage,
                    "since": sinceDate?.toISO8601
                ]
            )
        ) { (result) in
            switch result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601
                let apiCommits: [CommitNO]
                do {
                    apiCommits = try jsonDecoder.decode([CommitNO].self, from: data)
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
