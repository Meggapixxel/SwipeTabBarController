//
//  UmicoNavigationController.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 13.06.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

struct UmicoViewControllerNavigationBarItems: OptionSet {
    
    let rawValue: Int
    
    static let favourites    = UmicoViewControllerNavigationBarItems(rawValue: 1 << 0)
    static let notifications = UmicoViewControllerNavigationBarItems(rawValue: 1 << 1)
    static let search        = UmicoViewControllerNavigationBarItems(rawValue: 1 << 2)
    
    static let all: UmicoViewControllerNavigationBarItems = [.favourites, .notifications, .search]
    static let favouritesAndSearch: UmicoViewControllerNavigationBarItems = [.favourites, .search]
    static let notificationsAndSearch: UmicoViewControllerNavigationBarItems = [.notifications, .search]
    
}

protocol P_UmicoNavigationControllerChild: UIViewController {
    
    var navigationBarHidden: Bool { get }
    var navigationBarItems: UmicoViewControllerNavigationBarItems { get }
    
}

final class UmicoNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    private func prepare(viewController: P_UmicoNavigationControllerChild, animated: Bool) {
        if viewController.navigationBarHidden {
            guard !isNavigationBarHidden else { return }
            setNavigationBarHidden(true, animated: animated)
            interactivePopGestureRecognizer?.isEnabled = true
        } else {
            defer {
                var rightBarButtonItems = [UIBarButtonItem]()
                if viewController.navigationBarItems.contains(.favourites) {
                    rightBarButtonItems.append(favouritesBarButtonItem)
                }
                if viewController.navigationBarItems.contains(.notifications) {
                    rightBarButtonItems.append(notificationsBarButtonItem)
                }
                if viewController.navigationBarItems.contains(.search) {
                    rightBarButtonItems.append(searchBarButtonItem)
                }
                viewController.navigationItem.rightBarButtonItems = rightBarButtonItems
            }
            guard isNavigationBarHidden else { return }
            setNavigationBarHidden(false, animated: animated)
        }
    }
    
}

extension UmicoNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

extension UmicoNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print(#function, viewController)
        if let umicoNavigationControllerChild = viewController as? P_UmicoNavigationControllerChild {
            prepare(viewController: umicoNavigationControllerChild, animated: animated)
        } else {
            setNavigationBarHidden(false, animated: animated)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print(#function, viewController)
    }
    
}

private extension UmicoNavigationController {
    
    var favouritesBarButtonItem: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(favouritesTapped))
    }
    
    var notificationsBarButtonItem: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(notificationsTapped))
    }
    
    var searchBarButtonItem: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(searchTapped))
    }
    
}

// MARK: - Actions
private extension UmicoNavigationController {
    
    @objc func favouritesTapped() {
        // TODO: - logic
    }
    
    @objc func notificationsTapped() {
        // TODO: - logic
    }
    
    @objc func searchTapped() {
        // TODO: - logic
    }
    
}
