//
//  CGColor+UIColor.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 22.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

extension CGColor {
    
    var uiColor: UIColor { return UIColor(cgColor: self) }
    
}
