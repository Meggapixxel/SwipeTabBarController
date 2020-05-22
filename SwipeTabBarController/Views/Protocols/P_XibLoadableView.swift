//
//  P_XibLoadableView.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 22.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

protocol P_XibLoadableView: UIView {
    
}

extension P_XibLoadableView {
    
    static func loadFromXib() -> Self {
        let name = String(describing: Self.self)
        let nib = UINib(nibName: name, bundle: nil)
        let view = nib.instantiate(withOwner: nil).first as? Self
        return view ?? Self()
    }
    
}
