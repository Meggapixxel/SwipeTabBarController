//
//  GithubCommitNO.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

struct GithubCommitNO: Decodable {
    
    enum RootKeys: String, CodingKey {
        case sha, commit, url = "html_url"
    }
    
    enum CommitKeys: String, CodingKey {
        
        case message
        case committer
        
        enum CommitterKeys: String, CodingKey {
            case date, name
        }
        
    }
    
    let date: Date
    let message: String
    let sha: String
    let url: String
    let author: GithubCommitAuthorNO
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        sha = try container.decode(String.self, forKey: .sha)
        url = try container.decode(String.self, forKey: .url)
        
        let commitContainer = try container.nestedContainer(keyedBy: CommitKeys.self, forKey: .commit)
        message = try commitContainer.decode(String.self, forKey: .message)
        
        let committerContainer = try commitContainer.nestedContainer(keyedBy: CommitKeys.CommitterKeys.self, forKey: .committer)
        date = try committerContainer.decode(Date.self, forKey: .date)
        
        author = try commitContainer.decode(GithubCommitAuthorNO.self, forKey: .committer)
    }
    
}
