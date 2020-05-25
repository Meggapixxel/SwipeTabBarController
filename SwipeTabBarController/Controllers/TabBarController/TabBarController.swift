import UIKit

final class TabBarController: UITabBarController {
    
    private enum LocalConstants {
        
        static var cardViewHeight: CGFloat { 250 }
        static var animationCurve: UIView.AnimationCurve { .linear }
        static var animationPercentToFinish: CGFloat { 0.4 }
        
    }
    
    private lazy var sharedView = TabBarSharedView()
    
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
        guard let _ = selectedViewController?.tabBarChildViewController else { return }

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
        viewControllers?.forEach { $0.tabBarChildViewController?.scrollDelegate = nil }
    }
    
    func updateScrollDelegation() {
        viewControllers?.enumerated().forEach { (index, vc) in
            vc.tabBarChildViewController?.scrollDelegate = selectedIndex == index ? self : nil
        }
    }
    
    func updateScrollPosition(animated: Bool) {
        let sharedAdditionalTopContentInset: CGFloat
        if let currentTabBarChildViewController = viewControllers?[selectedIndex].tabBarChildViewController {
            sharedAdditionalTopContentInset = currentTabBarChildViewController.additionalTopContentInset
        } else {
            sharedAdditionalTopContentInset = LocalConstants.cardViewHeight
        }
        viewControllers?.compactMap { $0.tabBarChildViewController }.forEach { tabBarChildViewController in
            if sharedAdditionalTopContentInset == LocalConstants.cardViewHeight {
                tabBarChildViewController.updateScrollContentOffsetIfNeeded(to: 0, animated: false)
            }
            tabBarChildViewController.additionalTopContentInset = sharedAdditionalTopContentInset
        }
    }
    
    func updateInjectedView(selectedIndex: Int) {
        switch selectedIndex {
        case 0: sharedView.setPercentage(CGFloat(0))
        case 1: sharedView.setPercentage(CGFloat(1))
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
        setupScrollDelegateViewControllers()
        setupPanGestureRecognizer()
        setupInjectView()
        
        
//        viewControllers?.enumerated().forEach { (index, vc) in
//            if vc.tabBarChildViewController != nil {
//                selectedIndex = index
//                vc.loadViewIfNeeded()
//            }
//        }
//        selectedIndex = 0
    }
    
    func setupInjectView() {
        guard let tabBarChildViewController = viewControllers?.first?.tabBarChildViewController else { return }
        sharedView.translatesAutoresizingMaskIntoConstraints = false
        sharedView.heightAnchor.constraint(equalToConstant: LocalConstants.cardViewHeight).isActive = true
        tabBarChildViewController.inserSharedView(sharedView)
        // set initial value
        sharedView.layoutIfNeeded()
        sharedView.setPercentage(0)
    }
    
    func setupScrollDelegateViewControllers() {
        viewControllers?.forEach { $0.tabBarChildViewController?.additionalTopContentInset = LocalConstants.cardViewHeight }
        viewControllers?.first?.tabBarChildViewController?.scrollDelegate = self
    }
    
    func setupPanGestureRecognizer() {
        view.addGestureRecognizer(swipeInteractionPanGestureRecognizer)
    }
    
}

extension TabBarController: TabBarInteractiveAnimatorDelegate, TabBarTransitionAnimatorDelegate {
    
    func tabBarInteractiveAnimator(
        _ tabBarInteractiveAnimator: TabBarInteractiveAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        cancelWithDuration duration: TimeInterval,
        curve: UIView.AnimationCurve
    ) {
        guard let index = viewControllers?.firstIndex(of: fromVC) else { return }
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .init(curve: curve),
            animations: {
                self.updateInjectedView(selectedIndex: index)
            }, completion: { _ in
                self.updateScrollPosition(animated: false)
                self.updateScrollDelegation()
            }
        )
    }
    
    func tabBarInteractiveAnimator(
        _ tabBarInteractiveAnimator: TabBarInteractiveAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        finishWithDuration duration: TimeInterval,
        curve: UIView.AnimationCurve
    ) {
        guard let index = viewControllers?.firstIndex(of: toVC) else { return }
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .init(curve: curve),
            animations: {
                self.updateInjectedView(selectedIndex: index)
            }
        ) { (_) in
            self.updateScrollPosition(animated: false)
            self.updateScrollDelegation()
        }
    }
    
    func tabBarInteractiveAnimator(
        _ tabBarInteractiveAnimator: TabBarInteractiveAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        updateWithPercent percent: CGFloat
    ) {
        guard let index = viewControllers?.firstIndex(of: toVC) else { return }
        switch index {
        case 0: sharedView.setPercentage(1 - percent)
        case 1: sharedView.setPercentage(percent)
        default: break
        }
    }
    
    func tabBarTransitionAnimatorUpdate(
        _ tabBarTransitionAnimator: TabBarTransitionAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        updateWithDuration duration: TimeInterval,
        curve: UIView.AnimationCurve
    ) {
        guard let index = viewControllers?.firstIndex(of: toVC) else { return }
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .init(curve: curve),
            animations: { self.updateInjectedView(selectedIndex: index) }
        )
    }
    
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let fromTabBarChildViewController = fromVC.tabBarChildViewController,
            let toTabBarChildViewController = toVC.tabBarChildViewController,
            let fromVCIndex = tabBarController.viewControllers?.firstIndex(of: fromVC),
            let toVCIndex = tabBarController.viewControllers?.firstIndex(of: toVC)
            else { return nil }
        
        removeScrollDelegation()
        updateScrollPosition(animated: false)
        
        let swipeAnimationType: TabBarTransitionAnimator.SwipeAnimationType = (fromVCIndex > toVCIndex) ? .fromLeft : .fromRight
        switch animatedTransitioningType {
        case .tap:
            return TabBarTransitionAnimator(
                curve: LocalConstants.animationCurve,
                swipeAnimationType: swipeAnimationType,
                sharedView: sharedView,
                fromTabBarChildViewController: fromTabBarChildViewController,
                toTabBarChildViewController: toTabBarChildViewController,
                delegate: self
            )
        case .swipe:
            return TabBarTransitionAnimator(
                curve: LocalConstants.animationCurve,
                swipeAnimationType: swipeAnimationType,
                sharedView: sharedView,
                fromTabBarChildViewController: fromTabBarChildViewController,
                toTabBarChildViewController: toTabBarChildViewController,
                delegate: nil
            )
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print(#function)
        guard swipeInteractionPanGestureRecognizer.isEnabled,
            swipeInteractionPanGestureRecognizer.state == .began || swipeInteractionPanGestureRecognizer.state == .changed
            else { return nil }
        return TabBarInteractiveAnimator(
            gestureRecognizer: swipeInteractionPanGestureRecognizer,
            completionCurve: LocalConstants.animationCurve,
            percentToFinish: LocalConstants.animationPercentToFinish,
            delegate: self
        )
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print(#function)
        removeScrollDelegation()
        updateScrollPosition(animated: false)
        
        if let _ = viewController.tabBarChildViewController {
            swipeInteractionPanGestureRecognizer.isEnabled = true
        } else {
            swipeInteractionPanGestureRecognizer.isEnabled = false
        }
        
        return transitionCoordinator == nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(#function)
        updateScrollDelegation()
        if let _ = viewController.tabBarChildViewController {
            if transitionCoordinator == nil {
                updateInjectedView(selectedIndex: selectedIndex)
            }
            sharedView.isHidden = false
        } else {
            sharedView.isHidden = true
        }
    }
    
}

extension TabBarController: P_TabBarChildViewControllerDelegate {
    
    func tabBarChildViewController(
        _ tabBarChildViewController: P_TabBarChildViewController,
        scrollViewDidScroll scrollView: UIScrollView
    ) {
        let contentOffsetY = scrollView.contentOffset.y
        let additionalTopContentInset = tabBarChildViewController.additionalTopContentInset
        
        tabBarChildViewController.scrollDelegate = nil
        
        // Scrolling up, Card hidding
        if contentOffsetY > 0 && additionalTopContentInset > 0 && additionalTopContentInset - contentOffsetY < 0 {
            scrollView.contentOffset.y -= LocalConstants.cardViewHeight - additionalTopContentInset + contentOffsetY
            tabBarChildViewController.additionalTopContentInset = 0
        } else if contentOffsetY > 0 && additionalTopContentInset > 0 {
            scrollView.contentOffset.y = 0
            tabBarChildViewController.additionalTopContentInset -= contentOffsetY
        }
        // Scrolling down, Card showing
        else if contentOffsetY < 0 && additionalTopContentInset < LocalConstants.cardViewHeight && additionalTopContentInset - contentOffsetY > LocalConstants.cardViewHeight {
            scrollView.contentOffset.y -= LocalConstants.cardViewHeight - additionalTopContentInset + contentOffsetY
            tabBarChildViewController.additionalTopContentInset = LocalConstants.cardViewHeight
        } else if contentOffsetY < 0 && additionalTopContentInset < LocalConstants.cardViewHeight {
            scrollView.contentOffset.y = 0
            tabBarChildViewController.additionalTopContentInset -= contentOffsetY
        }
        
        tabBarChildViewController.scrollDelegate = self
        
        
//        // Scrolling up, Card hidding
//        if contentOffsetY > 0 && additionalTopContentInset > 0 {
//            if additionalTopContentInset - contentOffsetY < 0 {
//                scrollView.contentOffset.y -= LocalConstants.cardViewHeight - additionalTopContentInset + contentOffsetY
//                tabBarChildViewController.additionalTopContentInset = 0
//            } else {
//                scrollView.contentOffset.y = 0
//                tabBarChildViewController.additionalTopContentInset -= contentOffsetY
//            }
//        }
//        // Scrolling down, Card showing
//        else if contentOffsetY < 0 && additionalTopContentInset < LocalConstants.cardViewHeight {
//            if additionalTopContentInset - contentOffsetY > LocalConstants.cardViewHeight {
//                scrollView.contentOffset.y -= LocalConstants.cardViewHeight - additionalTopContentInset + contentOffsetY
//                tabBarChildViewController.additionalTopContentInset = LocalConstants.cardViewHeight
//            } else {
//                scrollView.contentOffset.y = 0
//                tabBarChildViewController.additionalTopContentInset -= contentOffsetY
//            }
//        }
    }
    
}
