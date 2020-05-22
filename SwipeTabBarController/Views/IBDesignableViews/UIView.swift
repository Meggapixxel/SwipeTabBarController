//
//  DesignableView.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 22.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable var masksToBounds: Bool {
        get { return layer.masksToBounds }
        set { layer.masksToBounds = newValue }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get { return layer.borderColor?.uiColor }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get { return layer.shadowColor?.uiColor }
        set { layer.shadowColor = newValue?.cgColor }
    }
    
}

@IBDesignable class CirclularView: DesignableView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = min(frame.height, frame.width) / 2
        masksToBounds = true
    }
    
}

@IBDesignable class TopRoundedView: DesignableView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
}

@IBDesignable class ViewSeparator: DesignableView {

    @IBInspectable var height: CGFloat = 1 {
        didSet { layoutIfNeeded() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width, height: height / UIScreen.main.scale))
    }
    
}
