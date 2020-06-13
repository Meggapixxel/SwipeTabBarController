//
//  DatabaseAuthorService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_DatabaseAuthorService: P_DatabaseModelService {
    
    typealias DO = AuthorDO
    typealias NO = AuthorNO
    
    func get(name: String, _ completion: @escaping (Result<DO?, DatabaseError>) -> Void)
    
    func save(networkObject: NO) throws -> DO
    
    func create(networkObject: NO) -> DO
    
}

final class DatabaseAuthorService: P_DatabaseAuthorService {
    
    private let client: P_CoreDataClient
    private let operationQueue: DispatchQueue
    private let completionQueue: DispatchQueue
    
    init(client: P_CoreDataClient, fetchQueue: DispatchQueue, completionQueue: DispatchQueue) {
        self.client = client
        self.operationQueue = fetchQueue
        self.completionQueue = completionQueue
    }
    
    func get(name: String, _ completion: @escaping (Result<DO?, DatabaseError>) -> Void) {
        managedObjects(
            client: client,
            operationQueue: operationQueue,
            completionQueue: completionQueue,
            sort: nil,
            predicate: DatabasePredicate<DO>.equals(keyPath: \.name, value: name),
            options: [.first]
        ) { (result: Result<[DO], DatabaseError>) in
            switch result {
            case .success(let models): completion(.success(models.first))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func save(networkObject: NO) throws -> DO {
        let model = self.create(networkObject: networkObject)
        try client.insertAndSave(model: model)
        return model
    }
    
    func create(networkObject: NO) -> DO {
        let model = client.model(type: AuthorDO.self)
        model.name = networkObject.name
        model.email = networkObject.email
        return model
    }
    
}
