//
//  P_DatabaseModelService.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 29.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

protocol P_DatabaseModelService: class {

    init(client: P_CoreDataClient, fetchQueue: DispatchQueue, completionQueue: DispatchQueue)
    
}

extension P_DatabaseModelService {
    
    init(client: P_CoreDataClient, fetchQueue: DispatchQueue = .global(), completionQueue: DispatchQueue = .main) {
        self.init(client: client, fetchQueue: fetchQueue, completionQueue: completionQueue)
    }
    
    func managedObjects<MO: P_DatabaseModel>(
        client: P_CoreDataClient,
        operationQueue: DispatchQueue,
        completionQueue: DispatchQueue,
        sort: P_DatabaseSort?,
        predicate: P_DatabasePredicate?,
        options: DatabaseFetchOptions,
        _ completion: @escaping (Result<[MO], DatabaseError>) -> Void
    ) {
        let request = MO.createFetchRequest()
        if let sort = sort {
            request.sortDescriptors = [sort.descriptor]
        }
        request.predicate = predicate?.predicate
        options.set(in: request)
        operationQueue.async {
            
            func finish(result: Result<[MO], DatabaseError>) {
                completionQueue.async {
                    completion(result)
                }
            }
            
            do {
                let commits = try client.fetch(request: request)
                finish(result: .success(commits))
            } catch {
                finish(result: .failure(.some(error)))
            }
        }
    }
    
}
