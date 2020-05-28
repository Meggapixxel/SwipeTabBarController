//
//  DatabaseCommitService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation


protocol P_DatabaseCommitService {
    
    typealias Model = Commit
    typealias ApiModel = API_Commit
    
    func getAll<T>(
        sort: DatabaseSort<Model, T>,
        predicate: DatabasePredicate<Model>?,
        _ completion: @escaping (Result<[Model], DatabaseError>) -> Void
    )
    
    func save(apiModel: ApiModel, _ completion: @escaping (Result<Model, DatabaseError>) -> Void)
    func save(apiModels: [ApiModel], _ completion: @escaping (Result<[Model], DatabaseError>) -> Void)
    
    func delete(model: Model) throws
    
    func latest() throws -> Model
    
    func create(apiModel: ApiModel) -> Model
    
}

class DatabaseCommitService: P_DatabaseCommitService {
    
    private let client: P_CoreDataClient
    private let operationQueue: DispatchQueue
    private let completionQueue: DispatchQueue
    
    private let authorService: P_DatabaseAuthorService
    
    init(client: P_CoreDataClient, authorService: P_DatabaseAuthorService, fetchQueue: DispatchQueue = .global(), completionQueue: DispatchQueue = .main) {
        self.client = client
        self.operationQueue = fetchQueue
        self.completionQueue = completionQueue
        self.authorService = authorService
    }
    
    func getAll<T>(sort: DatabaseSort<Model, T>, predicate: DatabasePredicate<Model>?, _ completion: @escaping (Result<[Model], DatabaseError>) -> Void) {
        let request = Model.createFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: sort.key, ascending: sort.isAscending)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate?.predicate
        operationQueue.async {
            
            func finish(result: Result<[Model], DatabaseError>) {
                self.completionQueue.async {
                    completion(result)
                }
            }
            
            do {
                let commits = try self.client.fetch(request: request)
                finish(result: .success(commits))
            } catch {
                finish(result: .failure(.some(error)))
            }
        }
    }
    
    func save(apiModel: ApiModel, _ completion: @escaping (Result<Model, DatabaseError>) -> Void) {
        operationQueue.async {
            let model = self.create(apiModel: apiModel)
            self.client.insertIfNeeded(model: model.author)
            self.client.insert(model: model)
            
            func finish(result: Result<Model, DatabaseError>) {
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
    
    func save(apiModels: [ApiModel], _ completion: @escaping (Result<[Model], DatabaseError>) -> Void) {
        operationQueue.async {
            var results = [Model]()
            
            apiModels.enumerated().forEach { (index, apiModel) in
                let model = self.create(apiModel: apiModel)
                self.client.insertIfNeeded(model: model.author)
                self.client.insert(model: model)
                results.append(model)
            }
            
            func finish(result: Result<[Model], DatabaseError>) {
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
    
    func delete(model: Model) throws {
        try client.deleteAndSave(model: model)
    }
    
    func latest() throws -> Model {
        let request = Commit.createFetchRequest()
        let databaseSort = DatabaseSort<Model, Date>.desc(\.date)
        let sort = NSSortDescriptor(key: databaseSort.key, ascending: databaseSort.isAscending)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        let models = try client.fetch(request: request)
        guard let model = models.first else {
            throw DatabaseError.notExist
        }
        return model
    }
    
    func create(apiModel: ApiModel) -> Model {
        let model = client.model(type: Commit.self)
        model.message = apiModel.message
        model.sha = apiModel.sha
        model.url = apiModel.url
        model.date = apiModel.date
        model.author = authorService.create(apiModel: apiModel.author)
        return model
    }
    
}
