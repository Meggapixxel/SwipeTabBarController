//
//  TabBarController.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private enum LocalConstants {
        
        static var cardViewHeight: CGFloat { 250 }
        
    }
    
    private lazy var injectView = CardView()
    private lazy var injectViewLeadingConstaint = injectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
    private lazy var injectViewTopConstaint = injectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
    
    /// Animated transition being used currently
    private enum AnimatedTransitioningType {
        case tap, swipe
    }
    private lazy var animatedTransitioningType = AnimatedTransitioningType.tap
    private lazy var swipeInteractionPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerSelector(_:)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
}

private extension TabBarController {
    
    /// Starts the transition by changing the selected index if the
    /// gesture allows it.
    ///
    /// - Parameter sender: gesture recognizer
    func beginInteractiveTransitionIfPossible(_ sender: UIPanGestureRecognizer) {
        guard selectedViewController as? ScrollDelegateViewController != nil else { return }

        let translation = sender.translation(in: view)
        
        if translation.x > 0 && selectedIndex == 1 { // Panning right, transition to the left view controller.
            selectedIndex -= 1
        } else if translation.x < 0 && selectedIndex == 0 { // Panning left, transition to the right view controller.
            selectedIndex += 1
        } else {
            // Don't reset the gesture recognizer if we skipped starting the
            // transition because we don't have a translation yet (and thus, could
            // not determine the transition direction).
            if !translation.equalTo(.zero) {
                // There is not a view controller to transition to, force the
                // gesture recognizer to fail.
                sender.isEnabled = false
                sender.isEnabled = true
                return
            }
        }
        
        transitionCoordinator?.animate(alongsideTransition: nil) { [unowned self] context in
            guard context.isCancelled && sender.state == .changed else { return }
            self.beginInteractiveTransitionIfPossible(sender)
        }
    }
    
    func removeScrollDelegation() {
        viewControllers?.compactMap { $0 as? ScrollDelegateViewController }
            .forEach { $0.scrollDelegate = nil }
    }
    
    func updateScrollDelegation() {
        viewControllers?.enumerated().forEach { (index, vc) in
            guard let vc = vc as? ScrollDelegateViewController else { return }
            vc.scrollDelegate = selectedIndex == index ? self : nil
        }
    }
    
    func updateScrollPosition(animated: Bool) {
        let positionY = -(LocalConstants.cardViewHeight + injectViewTopConstaint.constant)
        viewControllers?.compactMap { $0 as? ScrollDelegateViewController }
            .forEach { $0.setScrollPosition(y: positionY, animated: animated) }
    }
    
    func updateInjectedView(selectedIndex: Int) {
        switch selectedIndex {
        case 0: injectView.setPercentage(CGFloat(0))
        case 1: injectView.setPercentage(CGFloat(1))
        default: break
        }
    }
    
}

private extension TabBarController {
    
    @objc func panGestureRecognizerSelector(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            animatedTransitioningType = .tap
        }
        // Do not attempt to begin an interactive transition if one is already ongoing
        guard transitionCoordinator == nil else { return }
        
        if sender.state == .began {
            animatedTransitioningType = .swipe
        }

        if sender.state == .began || sender.state == .changed {
            beginInteractiveTransitionIfPossible(sender)
        }
    }
    
}

private extension TabBarController {
    
    func setup() {
        delegate = self
        setupInjectView()
        setupPanGestureRecognizer()
        setupScrollDelegateViewControllers()
    }
    
    func setupInjectView() {
        view.addSubview(injectView)
        injectView.translatesAutoresizingMaskIntoConstraints = false
        injectView.heightAnchor.constraint(equalToConstant: LocalConstants.cardViewHeight).isActive = true
        injectViewLeadingConstaint.isActive = true
        injectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        injectViewTopConstaint.isActive = true
    }
    
    func setupScrollDelegateViewControllers() {
        viewControllers?.compactMap { $0 as? ScrollDelegateViewController }
            .forEach { vc in
                vc.loadViewIfNeeded()
                vc.additionalTopContentInset = LocalConstants.cardViewHeight
                vc.setScrollPosition(y: -LocalConstants.cardViewHeight, animated: false)
            }
        
        guard let scrollDelegateViewController = viewControllers?.first as? ScrollDelegateViewController else { return }
        scrollDelegateViewController.scrollDelegate = self
    }
    
    func setupPanGestureRecognizer() {
        view.addGestureRecognizer(swipeInteractionPanGestureRecognizer)
    }
    
}

extension TabBarController: TabBarInteractiveAnimatorDelegate, TabBarTransitionAnimatorDelegate {
    
    func swipeInteractorCancel(fromVC: UIViewController, toVC: UIViewController, duration: TimeInterval) {
        guard let index = viewControllers?.firstIndex(of: fromVC) else { return }
        UIView.animate(
            withDuration: duration,
            animations: {
                self.updateInjectedView(selectedIndex: index)
            }
        ) { (_) in
            self.updateScrollPosition(animated: false)
            self.updateScrollDelegation()
        }
    }
    
    func swipeInteractorFinish(fromVC: UIViewController, toVC: UIViewController, duration: TimeInterval) {
        guard let index = viewControllers?.firstIndex(of: toVC) else { return }
        UIView.animate(
            withDuration: duration,
            animations: {
                self.updateInjectedView(selectedIndex: index)
            }
        ) { (_) in
            self.updateScrollPosition(animated: false)
            self.updateScrollDelegation()
        }
    }
    
    func swipeInteractorUpdate(fromVC: UIViewController, toVC: UIViewController, percentage: CGFloat) {
        guard (0...1).contains(percentage) else { return }
        guard let index = viewControllers?.firstIndex(of: toVC) else { return }
        switch index {
        case 0: injectView.setPercentage(1 - percentage)
        case 1: injectView.setPercentage(percentage)
        default: break
        }
    }
    
    func swipeTransitionAnimatorUpdate(fromVC: UIViewController, toVC: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: toVC) else { return }
        self.updateInjectedView(selectedIndex: index)
    }
    
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard fromVC as? ScrollDelegateViewController != nil,
            toVC as? ScrollDelegateViewController != nil,
            let fromVCIndex = tabBarController.viewControllers?.firstIndex(of: fromVC),
            let toVCIndex = tabBarController.viewControllers?.firstIndex(of: toVC)
            else { return nil }
        
        removeScrollDelegation()
        updateScrollPosition(animated: false)
        
        let animationType: TabBarTransitionAnimator.SwipeAnimationType = (fromVCIndex > toVCIndex) ? .fromLeft : .fromRight
        switch animatedTransitioningType {
        case .tap:
            return TabBarTransitionAnimator(
                animationType: animationType,
                delegate: self
            )
        case .swipe:
            return TabBarTransitionAnimator(
                animationType: animationType,
                delegate: nil
            )
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard swipeInteractionPanGestureRecognizer.isEnabled,
            swipeInteractionPanGestureRecognizer.state == .began || swipeInteractionPanGestureRecognizer.state == .changed
            else { return nil }
        return TabBarInteractiveAnimator(
            gestureRecognizer: swipeInteractionPanGestureRecognizer,
            delegate: self
        )
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        removeScrollDelegation()
        updateScrollPosition(animated: false)
        
        if let _ = viewController as? ScrollDelegateViewController {
            swipeInteractionPanGestureRecognizer.isEnabled = true
        } else {
            swipeInteractionPanGestureRecognizer.isEnabled = false
        }
        
        return transitionCoordinator == nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateScrollDelegation()
        if let _ = viewController as? ScrollDelegateViewController {
            if transitionCoordinator == nil {
                updateInjectedView(selectedIndex: selectedIndex)
            }
            injectView.isHidden = false
        } else {
            injectView.isHidden = true
        }
    }
    
}

extension TabBarController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            injectViewTopConstaint.constant = -(scrollView.contentOffset.y + LocalConstants.cardViewHeight)
        } else if injectViewTopConstaint.constant != -LocalConstants.cardViewHeight {
            injectViewTopConstaint.constant = -LocalConstants.cardViewHeight
        }
    }
    
}
