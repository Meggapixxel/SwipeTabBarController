//
//  NetworkClient.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 28.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation
import Alamofire

protocol P_NetworkClient {
    typealias NetworkClientCallback = ((Result<Data, NetworkClientError>) -> Void)
    func request(request: URLRequestConvertible, _ completion: @escaping NetworkClientCallback)
    func requestFormData(request: MultiFormDataRequestConvertible, _ completion: @escaping NetworkClientCallback)
}

class NetworkClient: P_NetworkClient {
    
    private let session: Alamofire.Session
    
    init(session: Alamofire.Session = .default) {
        self.session = session
    }
    
    func request(request: URLRequestConvertible, _ completion: @escaping NetworkClientCallback) {
        session.request(request)
            .validate(statusCode: 200..<300)
            .responseData { (dataResponse) in
                switch dataResponse.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(.some(error)))
                }
            }
    }
    
    func requestFormData(request: MultiFormDataRequestConvertible, _ completion: @escaping NetworkClientCallback) {
        session.upload(multipartFormData: request.encode, with: request)
            .validate(statusCode: 200..<300)
            .responseData { (dataResponse) in
                switch dataResponse.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(.some(error)))
                }
            }
    }
    
}
