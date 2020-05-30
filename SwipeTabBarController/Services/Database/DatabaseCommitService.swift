//
//  DatabaseCommitService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_DatabaseCommitService: P_DatabaseModelService {
    
    typealias MO = CommitMO
    typealias NO = CommitNO
    
    func get<T>(
        sort: DatabaseSort<MO, T>,
        predicate: DatabasePredicate<MO>?,
        options: DatabaseFetchOptions,
        _ completion: @escaping (Result<[MO], DatabaseError>) -> Void
    )
    
    func save(networkObject: NO, _ completion: @escaping (Result<MO, DatabaseError>) -> Void)
    func save(apiModels: [NO], _ completion: @escaping (Result<[MO], DatabaseError>) -> Void)
    
    func delete(model: MO) throws
    
    func latest(_ completion: @escaping (Result<MO?, DatabaseError>) -> Void)
    
    func create(networkObject: NO) -> MO
    
}
extension P_DatabaseCommitService {
    
    func get<T>(
        sort: DatabaseSort<MO, T>,
        predicate: DatabasePredicate<MO>?,
        _ completion: @escaping (Result<[MO], DatabaseError>) -> Void
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
    
    private let client: P_CoreDataClient
    private let operationQueue: DispatchQueue
    private let completionQueue: DispatchQueue
    private let authorService: DatabaseAuthorService
    
    init(client: P_CoreDataClient, fetchQueue: DispatchQueue, completionQueue: DispatchQueue) {
        self.client = client
        self.operationQueue = fetchQueue
        self.completionQueue = completionQueue
        self.authorService = DatabaseAuthorService(client: client, fetchQueue: fetchQueue, completionQueue: completionQueue)
    }
    
    func get<T>(
        sort: DatabaseSort<MO, T>,
        predicate: DatabasePredicate<MO>?,
        options: DatabaseFetchOptions,
        _ completion: @escaping (Result<[MO], DatabaseError>) -> Void
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
    
    func save(networkObject: NO, _ completion: @escaping (Result<MO, DatabaseError>) -> Void) {
        operationQueue.async {
            let model = self.create(networkObject: networkObject)
            self.client.insertIfNeeded(model: model.author)
            self.client.insert(model: model)
            
            func finish(result: Result<MO, DatabaseError>) {
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
    
    func save(apiModels: [NO], _ completion: @escaping (Result<[MO], DatabaseError>) -> Void) {
        operationQueue.async {
            var results = [MO]()
            
            apiModels.enumerated().forEach { (index, apiModel) in
                let model = self.create(networkObject: apiModel)
                self.client.insertIfNeeded(model: model.author)
                self.client.insert(model: model)
                results.append(model)
            }
            
            func finish(result: Result<[MO], DatabaseError>) {
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
    
    func delete(model: MO) throws {
        try client.deleteAndSave(model: model)
    }
    
    func latest(_ completion: @escaping (Result<MO?, DatabaseError>) -> Void) {
        managedObjects(
            client: client,
            operationQueue: operationQueue,
            completionQueue: completionQueue,
            sort: DatabaseSort<MO, Date>.desc(\.date),
            predicate: nil,
            options: [.first]
        ) { (result: Result<[MO], DatabaseError>) in
            switch result {
            case .success(let models): completion(.success(models.first))
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    func create(networkObject: NO) -> MO {
        let model = client.model(type: CommitMO.self)
        model.message = networkObject.message
        model.sha = networkObject.sha
        model.url = networkObject.url
        model.date = networkObject.date
        model.author = authorService.create(networkObject: networkObject.author)
        return model
    }
    
}
