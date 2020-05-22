//
//  AnimationOptions+AnimationCurve.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 21.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

extension UIView.AnimationOptions {
    
    init(curve: UIView.AnimationCurve) {
        switch curve {
        case .easeOut:   self = .curveEaseOut
        case .easeInOut: self = .curveEaseInOut
        case .linear:    self = .curveLinear
        default:         self = .curveEaseIn
        }
    }
    
}
