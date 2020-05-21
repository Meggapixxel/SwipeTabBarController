//
//  TabBarTransitionAnimator.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

protocol TabBarTransitionAnimatorDelegate: class {
    func swipeTransitionAnimatorUpdate(fromVC: UIViewController, toVC: UIViewController)
}

/// Swipe animation conforming to `UIViewControllerAnimatedTransitioning`
/// Can be replaced by any other class confirming to `UIViewControllerTransitioning`
/// on your `SwipeableTabBarController` subclass.
final class TabBarTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - SwipeTransitioningProtocol
    let animationDuration: TimeInterval
    let animationType: SwipeAnimationType
    weak var delegate: TabBarTransitionAnimatorDelegate?


    /// Init with injectable parameters
    ///
    /// - Parameters:
    ///   - animationDuration: time the transitioning animation takes to complete
    ///   - animationType: animation type to perform while transitioning
    init(
        animationDuration: TimeInterval = 0.33,
        animationType: SwipeAnimationType,
        delegate: TabBarTransitionAnimatorDelegate?
    ) {
        self.animationDuration = animationDuration
        self.animationType = animationType
        
        super.init()
        
        self.delegate = delegate
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let transitionContext = transitionContext else { return 0 }
        return transitionContext.isAnimated ? animationDuration : 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
            else { return transitionContext.completeTransition(false) }

        animationType.addTo(containerView: containerView, fromView: fromView, toView: toView)
        animationType.prepare(fromView: fromView, toView: toView)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveLinear],
            animations: {
                self.delegate?.swipeTransitionAnimatorUpdate(fromVC: fromVC, toVC: toVC)
                self.animationType.animation(fromView: fromView, toView: toView)
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
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
            switch self {
            default:
                containerView.addSubview(toView)
            }
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
