//
//  MultiFormDataRequestConvertible.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 30.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Alamofire

protocol MultiFormDataRequestConvertible: URLRequestConvertible {
    
    func encode(multipartFormData: MultipartFormData)
    
}
