//
//  NetworkRequestBodyParameters.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

enum NetworkRequestBodyParameters {
    case none, json([String: Any]), multipart([String: P_MultipartFormData])
}
