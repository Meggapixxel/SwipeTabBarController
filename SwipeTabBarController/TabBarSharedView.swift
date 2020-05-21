//
//  TabBarSharedView.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    var horizontal: CGFloat { left + right }
    var vertical: CGFloat { top + bottom }
    
}
class TabBarSharedView: UIView {
    
    private enum LocalConstants {
        
        static var cardContainerInsets: UIEdgeInsets { .init(top: 16, left: 16, bottom: 16, right: 16) }
        static var cardContainerMinLeading: CGFloat { 16 }
        static var cardContainerMaxLeading: CGFloat { 150 }
        
        static var cardContainerMinColor: UIColor { UIColor.systemGray6 }
        static var cardContainerMaxColor: UIColor { UIColor.systemGray3 }
        
    }
    
    private let cardContainer = UIView()
    private lazy var cardContainerTop = cardContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: LocalConstants.cardContainerInsets.top)
    private lazy var cardContainerBottom = cardContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -LocalConstants.cardContainerInsets.bottom)
    private lazy var cardContainerLeading = cardContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: LocalConstants.cardContainerMaxLeading)
    private lazy var cardContainerWidth = cardContainer.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -LocalConstants.cardContainerInsets.horizontal)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = LocalConstants.cardContainerMaxColor
        
        addSubview(cardContainer)
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainerTop.isActive = true
        cardContainerBottom.isActive = true
        cardContainerLeading.isActive = true
        cardContainerWidth.isActive = true
        cardContainer.backgroundColor = .white
        cardContainer.layer.cornerRadius = 8
        cardContainer.layer.shadowOffset = .zero
        cardContainer.layer.shadowRadius = 8
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.5
    }
    
    func setPercentage(_ percentage: CGFloat) {
        guard (0...1).contains(percentage) else { return }
        backgroundColor = LocalConstants.cardContainerMaxColor.toColor(LocalConstants.cardContainerMinColor, percentage: percentage)
        cardContainerLeading.constant = LocalConstants.cardContainerMaxLeading - (LocalConstants.cardContainerMaxLeading - LocalConstants.cardContainerMinLeading) * percentage
        layoutIfNeeded()
    }
    
}

private extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 1), 0)
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(
                red: CGFloat(r1 + (r2 - r1) * percentage),
                green: CGFloat(g1 + (g2 - g1) * percentage),
                blue: CGFloat(b1 + (b2 - b1) * percentage),
                alpha: CGFloat(a1 + (a2 - a1) * percentage)
            )
        }
    }
}
