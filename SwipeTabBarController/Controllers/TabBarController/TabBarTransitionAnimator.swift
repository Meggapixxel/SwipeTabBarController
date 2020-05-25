import UIKit

protocol TabBarTransitionAnimatorDelegate: class {
    
    func tabBarTransitionAnimatorUpdate(
        _ tabBarTransitionAnimator: TabBarTransitionAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        updateWithDuration duration: TimeInterval,
        curve: UIView.AnimationCurve
    )
    
}

/// Swipe animation conforming to `UIViewControllerAnimatedTransitioning`
/// Can be replaced by any other class confirming to `UIViewControllerTransitioning`
/// on your `SwipeableTabBarController` subclass.
final class TabBarTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    let curve: UIView.AnimationCurve
    let swipeAnimationType: SwipeAnimationType
    let sharedView: UIView
    private(set) weak var fromTabBarChildViewController: P_TabBarChildViewController?
    private(set) weak var toTabBarChildViewController: P_TabBarChildViewController?
    weak var delegate: TabBarTransitionAnimatorDelegate?


    /// Init with injectable parameters
    ///
    /// - Parameters:
    ///   - duration: time the transitioning animation takes to complete
    ///   - curve: curve to perform transitioning
    ///   - swipeAnimationType: animation type to perform while transitioning
    init(
        duration: TimeInterval = 0.33,
        curve: UIView.AnimationCurve = .linear,
        swipeAnimationType: SwipeAnimationType,
        sharedView: UIView,
        fromTabBarChildViewController: P_TabBarChildViewController,
        toTabBarChildViewController: P_TabBarChildViewController,
        delegate: TabBarTransitionAnimatorDelegate?
    ) {
        self.duration = duration
        self.curve = curve
        self.swipeAnimationType = swipeAnimationType
        self.sharedView = sharedView
        self.fromTabBarChildViewController = fromTabBarChildViewController
        self.toTabBarChildViewController = toTabBarChildViewController
        
        super.init()
        
        self.delegate = delegate
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let transitionContext = transitionContext else { return 0 }
        return transitionContext.isAnimated ? duration : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let fromTabBarChildViewController = fromTabBarChildViewController,
            let toTabBarChildViewController = toTabBarChildViewController,
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else { return transitionContext.completeTransition(false) }
        
        let snapshotFrame = CGRect(
            x: 0,
            y: 0,
            width: fromTabBarChildViewController.view.frame.width,
            height: fromTabBarChildViewController.view.frame.origin.y
        )
        let fromSnapshot = fromVC.view.snapshotViewImageView(cgRect: snapshotFrame)
        let toSnapshot = fromVC.view.snapshotViewImageView(cgRect: snapshotFrame)
        
        swipeAnimationType.addTo(containerView: containerView, fromView: fromView, toView: toView)
        swipeAnimationType.prepare(fromView: fromView, toView: toView)
       
        let topConst = sharedView.globalFrame(baseView: nil).origin.y
        sharedView.removeFromSuperview()
        containerView.addSubview(sharedView)
        sharedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        sharedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        sharedView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topConst).isActive = true

        containerView.addSubview(fromSnapshot)
        containerView.addSubview(toSnapshot)
        swipeAnimationType.prepare(fromView: fromSnapshot, toView: toSnapshot)
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .init(curve: curve),
            animations: {
                self.swipeAnimationType.animation(fromView: fromView, toView: toView)
                self.swipeAnimationType.animation(fromView: fromSnapshot, toView: toSnapshot)
            }, completion: { _ in
                self.sharedView.removeFromSuperview()
                if transitionContext.transitionWasCancelled {
                    fromTabBarChildViewController.inserSharedView(self.sharedView)
                    transitionContext.completeTransition(false)
                } else {
                    toTabBarChildViewController.inserSharedView(self.sharedView)
                    transitionContext.completeTransition(true)
                }
                fromSnapshot.removeFromSuperview()
                toSnapshot.removeFromSuperview()
            }
        )
        delegate?.tabBarTransitionAnimatorUpdate(
            self,
            fromVC: fromVC,
            toVC: toVC,
            updateWithDuration: duration,
            curve: curve
        )
    }
    
}

extension TabBarTransitionAnimator {
    
    /// Different types of interactive animations.
    ///
    /// - overlap: Previously selected tab will stay in place while the new tab slides in.
    /// - sideBySide: Both tabs move side by side as the animation takes place.
    /// - push: Replicates iOS default push animation.
    enum SwipeAnimationType {
        
        case fromLeft
        case fromRight
        
        /// Setup the views hirearchy for different animations types.
        ///
        /// - Parameters:
        ///   - containerView: View that will contain the tabs views that will perform the animation
        ///   - fromView: Previously selected tab view.
        ///   - toView: New selected tab view.
        func addTo(containerView: UIView, fromView: UIView, toView: UIView) {
            containerView.addSubview(toView)
        }
        
        /// Setup the views position prior to the animation start.
        ///
        /// - Parameters:
        ///   - from: Previously selected tab view.
        ///   - to: New selected tab view.
        ///   - direction: Direction in which the views will animate.
        func prepare(fromView from: UIView, toView to: UIView) {
            let screenWidth = UIScreen.main.bounds.size.width
            switch self {
            case .fromLeft:
                from.frame.origin.x = 0
                to.frame.origin.x = -screenWidth
            case .fromRight:
                from.frame.origin.x = 0
                to.frame.origin.x = screenWidth
            }
        }

        /// The animation to take place.
        ///
        /// - Parameters:
        ///   - from: Previously selected tab view.
        ///   - to: New selected tab view.
        ///   - direction: Direction in which the views will animate.
        func animation(fromView from: UIView, toView to: UIView) {
            let screenWidth = UIScreen.main.bounds.size.width
            switch self {
            case .fromLeft:
                from.frame.origin.x = screenWidth
                to.frame.origin.x = 0
            case .fromRight:
                from.frame.origin.x = -screenWidth
                to.frame.origin.x = 0
            }
        }
        
    }

}

private extension UIView {

    func globalPoint(baseView: UIView?) -> CGPoint {
        var pnt = self.frame.origin
        guard var superView = self.superview else { return pnt }
        while superView != baseView {
            pnt = superView.convert(pnt, to: superView.superview)
            guard let superSuperview = superView.superview else { break }
            superView = superSuperview
        }
        return superView.convert(pnt, to: baseView)
    }

    func globalFrame(baseView: UIView?) -> CGRect {
        var pnt = self.frame
        guard var superView = self.superview else { return pnt }
        while superView != baseView {
            pnt = superView.convert(pnt, to: superView.superview)
            guard let superSuperview = superView.superview else { break }
            superView = superSuperview
        }
        return superView.convert(pnt, to: baseView)
    }

}
