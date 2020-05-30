//
//  DatabaseAuthorService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_DatabaseAuthorService: P_DatabaseModelService {
    
    typealias MO = AuthorMO
    typealias NO = AuthorNO
    
    func get(name: String, _ completion: @escaping (Result<MO?, DatabaseError>) -> Void)
    
    func save(networkObject: NO) throws -> MO
    
    func create(networkObject: NO) -> MO
    
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
    
    func get(name: String, _ completion: @escaping (Result<MO?, DatabaseError>) -> Void) {
        managedObjects(
            client: client,
            operationQueue: operationQueue,
            completionQueue: completionQueue,
            sort: nil,
            predicate: DatabasePredicate<MO>.equals(keyPath: \.name, value: name),
            options: [.first]
        ) { (result: Result<[MO], DatabaseError>) in
            switch result {
            case .success(let models): completion(.success(models.first))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func save(networkObject: NO) throws -> MO {
        let model = self.create(networkObject: networkObject)
        try client.insertAndSave(model: model)
        return model
    }
    
    func create(networkObject: NO) -> MO {
        let model = client.model(type: AuthorMO.self)
        model.name = networkObject.name
        model.email = networkObject.email
        return model
    }
    
}
