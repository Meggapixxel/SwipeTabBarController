//
//  TabBarChildViewController.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 21.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

protocol TabBarChildViewController: UIViewController, UIScrollViewDelegate {
    var scrollDelegate: UIScrollViewDelegate! { get set }
    var additionalTopContentInset: CGFloat { get set }
    func updateScrollContentOffsetIfNeeded(to y: CGFloat, animated: Bool)
}
