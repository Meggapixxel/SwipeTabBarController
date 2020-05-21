//
//  ViewController.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

class BaseScrollDelegateViewController: UIViewController, TabBarChildViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    
    weak var scrollDelegate: UIScrollViewDelegate!
    var additionalTopContentInset: CGFloat = 0 {
        didSet {
            tableView?.contentInset.top = additionalTopContentInset
            tableView?.verticalScrollIndicatorInsets.top = additionalTopContentInset
        }
    }
    private var restoredScrollViewContentOffset = CGPoint.zero
    func setScrollContentOffset(y: CGFloat, animated: Bool) {
        let contentOffset = CGPoint(x: 0, y: y)
        restoredScrollViewContentOffset = contentOffset
        tableView?.setContentOffset(contentOffset, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = additionalTopContentInset
        tableView.contentOffset = restoredScrollViewContentOffset
        tableView.verticalScrollIndicatorInsets.top = additionalTopContentInset
        tableView.dataSource = self
        tableView.delegate = self
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = indexPath.description
        return cell
    }
    
}

final class ViewController0: BaseScrollDelegateViewController {


}

final class ViewController1: BaseScrollDelegateViewController {

    

}

final class ViewController2: UIViewController {

    

}
