//
//  TabBarTransitionAnimator.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

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
        delegate: TabBarTransitionAnimatorDelegate?
    ) {
        self.duration = duration
        self.curve = curve
        self.swipeAnimationType = swipeAnimationType
        
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

        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else { return transitionContext.completeTransition(false) }

        swipeAnimationType.addTo(containerView: containerView, fromView: fromView, toView: toView)
        swipeAnimationType.prepare(fromView: fromView, toView: toView)
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .init(curve: curve),
            animations: {
                self.swipeAnimationType.animation(fromView: fromView, toView: toView)
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
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
