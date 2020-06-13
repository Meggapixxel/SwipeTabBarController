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
    func request(request: P_NetworkRequest, _ completion: @escaping NetworkClientCallback)
}


private extension NetworkRequestMethod {
    
    var alamofire: HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .patch: return .patch
        case .delete: return .delete
        }
    }
    
}

final class NetworkClient: P_NetworkClient {
    
    private let session: Alamofire.Session
    
    init(session: Alamofire.Session = .default) {
        self.session = session
    }
    
    func request(request: P_NetworkRequest, _ completion: @escaping NetworkClientCallback) {
        guard let url = request.makeUrl() else { return completion(.failure(.invalidUrl)) }
        
        let method: HTTPMethod = request.method.alamofire
        
        let urlRequest: DataRequest
        switch request.body {
        case .json(let dict):      urlRequest = json(url: url, method: method, dict: dict)
        case .multipart(let dict): urlRequest = multipart(url: url, method: method, dict: dict)
        case .none:                urlRequest = session.request(url, method: method, headers: nil)
        }
        
        urlRequest.validate(statusCode: 200..<300)
            .responseData { (dataResponse) in
                switch dataResponse.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(.some(error)))
                }
            }
    }
    
}

private extension NetworkClient {
    
    func json(url: URL, method: HTTPMethod, dict: [String : Any]) -> DataRequest {
        session.request(
            url,
            method: method,
            parameters: dict,
            encoding: JSONEncoding.default,
            headers: nil
        )
    }
    
    func multipart(url: URL, method: HTTPMethod, dict: [String : P_MultipartFormData]) -> UploadRequest {
        session.upload(
            multipartFormData: { multipartFormData in
                dict.forEach { (key, value) in
                    multipartFormData.append(value.data, withName: key, fileName: value.name, mimeType: value.mimeType)
                }
            },
            to: url,
            method: method,
            headers: nil
        )
    }
    
}
