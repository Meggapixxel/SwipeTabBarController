//
//  DatabaseCommitService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_DatabaseCommitService: P_DatabaseModelService {
    
    typealias DO = CommitDO
    typealias NO = CommitNO
    
    func get<T>(
        sort: DatabaseSort<DO, T>,
        predicate: DatabasePredicate<DO>?,
        options: DatabaseFetchOptions,
        _ completion: @escaping (Result<[DO], DatabaseError>) -> Void
    )
    
    func save(networkObject: NO, _ completion: @escaping (Result<DO, DatabaseError>) -> Void)
    func save(apiModels: [NO], _ completion: @escaping (Result<[DO], DatabaseError>) -> Void)
    
    func delete(model: DO) throws
    
    func latest(_ completion: @escaping (Result<DO?, DatabaseError>) -> Void)
    
    func create(networkObject: NO) -> DO
    
}
extension P_DatabaseCommitService {
    
    func get<T>(
        sort: DatabaseSort<DO, T>,
        predicate: DatabasePredicate<DO>?,
        _ completion: @escaping (Result<[DO], DatabaseError>) -> Void
    ) {
        get(
            sort: sort,
            predicate: predicate,
            options: [],
            completion
        )
    }
    
}

final class DatabaseCommitService<DatabaseAuthorService: P_DatabaseAuthorService>: P_DatabaseCommitService {
    
    private let client: P_DatabaseClient
    private let operationQueue: DispatchQueue
    private let completionQueue: DispatchQueue
    private let authorService: DatabaseAuthorService
    
    init(client: P_DatabaseClient, fetchQueue: DispatchQueue, completionQueue: DispatchQueue) {
        self.client = client
        self.operationQueue = fetchQueue
        self.completionQueue = completionQueue
        self.authorService = DatabaseAuthorService(client: client, fetchQueue: fetchQueue, completionQueue: completionQueue)
    }
    
    func get<T>(
        sort: DatabaseSort<DO, T>,
        predicate: DatabasePredicate<DO>?,
        options: DatabaseFetchOptions,
        _ completion: @escaping (Result<[DO], DatabaseError>) -> Void
    ) {
        managedObjects(
            client: client,
            operationQueue: operationQueue,
            completionQueue: completionQueue,
            sort: sort,
            predicate: predicate,
            options: options,
            completion
        )
    }
    
    func save(networkObject: NO, _ completion: @escaping (Result<DO, DatabaseError>) -> Void) {
        operationQueue.async {
            let model = self.create(networkObject: networkObject)
            self.client.insertIfNeeded(model: model.author)
            self.client.insert(model: model)
            
            func finish(result: Result<DO, DatabaseError>) {
                self.completionQueue.async {
                    completion(result)
                }
            }
            
            do {
                try self.client.saveContext()
                finish(result: .success(model))
            } catch {
                finish(result: .failure(.some(error)))
            }
        }
    }
    
    func save(apiModels: [NO], _ completion: @escaping (Result<[DO], DatabaseError>) -> Void) {
        operationQueue.async {
            var results = [DO]()
            
            apiModels.enumerated().forEach { (index, apiModel) in
                let model = self.create(networkObject: apiModel)
                self.client.insertIfNeeded(model: model.author)
                self.client.insert(model: model)
                results.append(model)
            }
            
            func finish(result: Result<[DO], DatabaseError>) {
                self.completionQueue.async {
                    completion(result)
                }
            }
            
            do {
                try self.client.saveContext()
                finish(result: .success(results))
            } catch {
                finish(result: .failure(.some(error)))
            }
        }
    }
    
    func delete(model: DO) throws {
        try client.deleteAndSave(model: model)
    }
    
    func latest(_ completion: @escaping (Result<DO?, DatabaseError>) -> Void) {
        managedObjects(
            client: client,
            operationQueue: operationQueue,
            completionQueue: completionQueue,
            sort: DatabaseSort<DO, Date>.desc(\.date),
            predicate: nil,
            options: [.first]
        ) { (result: Result<[DO], DatabaseError>) in
            switch result {
            case .success(let models): completion(.success(models.first))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func create(networkObject: NO) -> DO {
        let model = client.model(type: CommitDO.self)
        model.message = networkObject.message
        model.sha = networkObject.sha
        model.url = networkObject.url
        model.date = networkObject.date
        model.author = authorService.create(networkObject: networkObject.author)
        return model
    }
    
}
