import UIKit

final class TabBarController: UITabBarController {
    
    private enum LocalConstants {
        
        static var cardViewHeight: CGFloat { 250 }
        static var animationCurve: UIView.AnimationCurve { .linear }
        static var animationPercentToFinish: CGFloat { 0.4 }
        
    }
    
    private lazy var sharedView = TabBarSharedView()
    private lazy var sharedViewLeadingConstaint = sharedView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    private lazy var sharedViewTopConstaint = sharedView.topAnchor.constraint(equalTo: view.topAnchor)
    
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
        guard selectedViewController as? TabBarChildViewController != nil else { return }

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
        viewControllers?.compactMap { $0 as? TabBarChildViewController }
            .forEach { $0.scrollDelegate = nil }
    }
    
    func updateScrollDelegation() {
        viewControllers?.enumerated().forEach { (index, vc) in
            guard let vc = vc as? TabBarChildViewController else { return }
            vc.scrollDelegate = selectedIndex == index ? self : nil
        }
    }
    
    func updateScrollPosition(animated: Bool) {
        let positionY = -(LocalConstants.cardViewHeight + sharedViewTopConstaint.constant)
        viewControllers?.compactMap { $0 as? TabBarChildViewController }
            .forEach { $0.updateScrollContentOffsetIfNeeded(to: positionY, animated: animated) }
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
        setupInjectView()
        setupPanGestureRecognizer()
        setupScrollDelegateViewControllers()
    }
    
    func setupInjectView() {
        view.addSubview(sharedView)
        sharedView.translatesAutoresizingMaskIntoConstraints = false
        sharedView.heightAnchor.constraint(equalToConstant: LocalConstants.cardViewHeight).isActive = true
        sharedViewLeadingConstaint.isActive = true
        sharedView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sharedViewTopConstaint.isActive = true
        
        // set initial value
        sharedView.layoutIfNeeded()
        sharedView.setPercentage(0)
    }
    
    func setupScrollDelegateViewControllers() {
        viewControllers?.compactMap { $0 as? TabBarChildViewController }
            .forEach { vc in
                vc.loadViewIfNeeded()
                vc.additionalTopContentInset = LocalConstants.cardViewHeight
                vc.updateScrollContentOffsetIfNeeded(to: -LocalConstants.cardViewHeight, animated: false)
            }
        
        guard let scrollDelegateViewController = viewControllers?.first as? TabBarChildViewController else { return }
        scrollDelegateViewController.scrollDelegate = self
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
        guard fromVC as? TabBarChildViewController != nil,
            toVC as? TabBarChildViewController != nil,
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
                delegate: self
            )
        case .swipe:
            return TabBarTransitionAnimator(
                curve: LocalConstants.animationCurve,
                swipeAnimationType: swipeAnimationType,
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
            completionCurve: LocalConstants.animationCurve,
            percentToFinish: LocalConstants.animationPercentToFinish,
            delegate: self
        )
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        removeScrollDelegation()
        updateScrollPosition(animated: false)
        
        if let _ = viewController as? TabBarChildViewController {
            swipeInteractionPanGestureRecognizer.isEnabled = true
        } else {
            swipeInteractionPanGestureRecognizer.isEnabled = false
        }
        
        return transitionCoordinator == nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateScrollDelegation()
        if let _ = viewController as? TabBarChildViewController {
            if transitionCoordinator == nil {
                updateInjectedView(selectedIndex: selectedIndex)
            }
            sharedView.isHidden = false
        } else {
            sharedView.isHidden = true
        }
    }
    
}

extension TabBarController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            sharedViewTopConstaint.constant = -(scrollView.contentOffset.y + LocalConstants.cardViewHeight)
        } else if sharedViewTopConstaint.constant != -LocalConstants.cardViewHeight {
            sharedViewTopConstaint.constant = -LocalConstants.cardViewHeight
        }
    }
    
}
