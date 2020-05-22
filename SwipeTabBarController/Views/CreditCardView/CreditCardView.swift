//
//  CreditCardView.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 22.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

@IBDesignable class CreditCardView: DesignableView, P_XibLoadableView {
    
    @IBOutlet private weak var digits0: UILabel!
    @IBOutlet private weak var digits1: UILabel!
    @IBOutlet private weak var digits2: UILabel!
    @IBOutlet private weak var digits3: UILabel!
    @IBOutlet private weak var expirationDate: UILabel!
    
    var alphaThreshold: CGFloat = 0.5
    
    func updateAlphaForDigits(alpha: CGFloat) {
        let approximatedAlpha = (alpha - alphaThreshold) / alphaThreshold
        digits1.alpha = approximatedAlpha
        digits2.alpha = approximatedAlpha
        digits3.alpha = approximatedAlpha
        expirationDate.alpha = approximatedAlpha
    }
    
}
