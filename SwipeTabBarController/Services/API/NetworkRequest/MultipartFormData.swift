//
//  P_MultipartFormData.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 30.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation
import Alamofire

protocol P_MultipartFormData {
    var data: Data { get }
    var name: String? { get }
    var mimeType: String? { get }
}

struct MultipartFormData: P_MultipartFormData {
    
    let data: Data
    let name: String?
    let mimeType: String?

    static func jpeg(data: Data, name: String) -> MultipartFormData {
        .init(
            data: data,
            name: name,
            mimeType: "image/jpeg"
        )
    }
    
    static func png(data: Data, name: String) -> MultipartFormData {
        .init(
            data: data,
            name: name,
            mimeType: "image/png"
        )
    }
    
}
