//
//  DatabaseAuthorService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_DatabaseAuthorService {
    
    typealias Model = Author
    typealias ApiModel = API_Author
    
    func get(name: String, _ completion: @escaping (Result<Model, DatabaseError>) -> Void)
    
    func save(apiModel: ApiModel) throws -> Model
    
    func create(apiModel: ApiModel) -> Model
    
}

class DatabaseAuthorService: P_DatabaseAuthorService {
    
    private let client: P_CoreDataClient
    private let fetchQueue: DispatchQueue
    private let completionQueue: DispatchQueue
    
    init(client: P_CoreDataClient, fetchQueue: DispatchQueue = .global(), completionQueue: DispatchQueue = .main) {
        self.client = client
        self.fetchQueue = fetchQueue
        self.completionQueue = completionQueue
    }
    
    func get(name: String, _ completion: @escaping (Result<Model, DatabaseError>) -> Void) {
        fetchQueue.async {
            let request = Model.createFetchRequest()
            request.predicate = DatabasePredicate<Model>.equals(keyPath: \.name, value: name).predicate
            
            func finish(result: Result<Model, DatabaseError>) {
                self.completionQueue.async {
                    completion(result)
                }
            }
            
            let models: [Model]
            do {
                models = try self.client.fetch(request: request)
            } catch {
                return finish(result: .failure(.some(error)))
            }
            if let model = models.first {
                finish(result: .success(model))
            } else {
                finish(result: .failure(.notExist))
            }
        }
    }
    
    func save(apiModel: ApiModel) throws -> Model {
        let model = self.create(apiModel: apiModel)
        try client.insertAndSave(model: model)
        return model
    }
    
    func create(apiModel: ApiModel) -> Model {
        let model = client.model(type: Author.self)
        model.name = apiModel.name
        model.email = apiModel.email
        return model
    }
    
}
