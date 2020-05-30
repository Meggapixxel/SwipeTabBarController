//
//  ApiClient.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 28.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

enum ApiError: Error {
    case some(Error), invalidUrl
}

class ApiClient {
    
    func fetchCommits(perPage: Int = 100, sinceDate: Date? = nil, _ completion: @escaping (Result<[CommitNO], ApiError>) -> Void) {
        var urlString = "https://api.github.com/repos/apple/swift/commits?per_page=\(perPage)"
        if let sinceDate = sinceDate {
            let formattedDate = ISO8601DateFormatter().string(from: sinceDate.addingTimeInterval(1))
            urlString.append("&since=\(formattedDate)")
        }
        guard let url = URL(string: urlString) else { return completion(.failure(.invalidUrl)) }
        
        DispatchQueue.global().async {
            func complete(_ result: Result<[CommitNO], ApiError>) {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            let dataString: String
            do {
                dataString = try String(contentsOf: url)
            } catch {
                return complete(.failure(.some(error)))
            }
            let data = dataString.data(using: .utf8)!
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            
            let apiCommits: [CommitNO]
            do {
                apiCommits = try jsonDecoder.decode([CommitNO].self, from: data)
            } catch {
                return complete(.failure(.some(error)))
            }
            complete(.success(apiCommits))
        }
    }
    
}
