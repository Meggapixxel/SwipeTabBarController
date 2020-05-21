//
//  ViewController.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

class BaseScrollDelegateViewController: UIViewController, TabBarChildViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    weak var scrollDelegate: UIScrollViewDelegate!
    var additionalTopContentInset: CGFloat = 0 {
        didSet {
            scrollView?.contentInset.top = additionalTopContentInset
            scrollView?.verticalScrollIndicatorInsets.top = additionalTopContentInset
        }
    }
    private var restoredScrollViewContentOffset = CGPoint.zero
    func setScrollContentOffset(y: CGFloat, animated: Bool) {
        let contentOffset = CGPoint(x: 0, y: y)
        restoredScrollViewContentOffset = contentOffset
        scrollView?.setContentOffset(contentOffset, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInset.top = additionalTopContentInset
        scrollView.contentOffset = restoredScrollViewContentOffset
        scrollView.verticalScrollIndicatorInsets.top = additionalTopContentInset
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
}

final class ViewController0: BaseScrollDelegateViewController {


}

final class ViewController1: BaseScrollDelegateViewController {

    

}

final class ViewController2: UIViewController {

    

}
