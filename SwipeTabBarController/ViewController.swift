//
//  ViewController.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

protocol ScrollDelegateViewController: UIViewController, UIScrollViewDelegate {
    var scrollDelegate: UIScrollViewDelegate! { get set }
    var additionalTopContentInset: CGFloat { get set }
    func setScrollPosition(y: CGFloat, animated: Bool)
}

class BaseScrollDelegateViewController: UIViewController, ScrollDelegateViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    weak var scrollDelegate: UIScrollViewDelegate!
    var additionalTopContentInset: CGFloat = 0 {
        didSet {
            scrollView?.contentInset.top = additionalTopContentInset
            scrollView?.verticalScrollIndicatorInsets.top = additionalTopContentInset
        }
    }
    private var restoredScrollViewContentOffset = CGPoint.zero
    func setScrollPosition(y: CGFloat, animated: Bool) {
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
