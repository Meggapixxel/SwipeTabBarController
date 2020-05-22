//
//  TabBarInteractiveAnimator.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

protocol TabBarInteractiveAnimatorDelegate: class {
    
    func tabBarInteractiveAnimator(
        _ tabBarInteractiveAnimator: TabBarInteractiveAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        cancelWithDuration duration: TimeInterval,
        curve: UIView.AnimationCurve
    )
    
    func tabBarInteractiveAnimator(
        _ tabBarInteractiveAnimator: TabBarInteractiveAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        finishWithDuration duration: TimeInterval,
        curve: UIView.AnimationCurve
    )
    
    func tabBarInteractiveAnimator(
        _ tabBarInteractiveAnimator: TabBarInteractiveAnimator,
        fromVC: UIViewController,
        toVC: UIViewController,
        updateWithPercent percent: CGFloat
    )
    
}

final class TabBarInteractiveAnimator: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Private
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private let gestureRecognizer: UIPanGestureRecognizer
    private let percentToFinish: CGFloat
    private var initialTranslationInContainerView = CGPoint()
    
    weak var delegate: TabBarInteractiveAnimatorDelegate?
    
    init(
        gestureRecognizer: UIPanGestureRecognizer,
        completionCurve: UIView.AnimationCurve = .linear,
        percentToFinish: CGFloat = 0.5,
        delegate: TabBarInteractiveAnimatorDelegate?
    ) {
        self.gestureRecognizer = gestureRecognizer
        self.percentToFinish = percentToFinish
        
        super.init()
        
        self.completionCurve = completionCurve
        self.delegate = delegate
        
        // Add self as an observer of the gesture recognizer so that this
        // object receives updates as the user moves their finger.
        gestureRecognizer.addTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
    }

    deinit {
        gestureRecognizer.removeTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        // Save the transitionContext, initial location, and the translation within
        // the containing view.
        self.transitionContext = transitionContext
        initialTranslationInContainerView = gestureRecognizer.translation(in: transitionContext.containerView)

        super.startInteractiveTransition(transitionContext)
    }
    
}

private extension TabBarInteractiveAnimator {

    /// Returns the offset of the pan gesture recognizer from its initial location
    /// as a percentage of the transition container view's width.
    ///
    /// - Parameter gesture: swiping gesture
    /// - Returns: percent completed for the interactive transition
    func percentForGesture(_ gesture: UIPanGestureRecognizer) -> CGFloat {
        guard let transitionContext = transitionContext else { return 0 }
        let transitionContainerView = transitionContext.containerView
        
        let translationInContainerView = gesture.translation(in: transitionContainerView)
        
        // If the direction of the current touch along the horizontal axis does not
        // match the initial direction, then the current touch position along
        // the horizontal axis has crossed over the initial position.
        if translationInContainerView.x > 0 && initialTranslationInContainerView.x < 0 ||
            translationInContainerView.x < 0 && initialTranslationInContainerView.x > 0 {
            return -1
        }
        
        // Figure out what percentage we've traveled.
        return abs(translationInContainerView.x) / (transitionContainerView.bounds).width
    }
    
    @objc func gestureRecognizeDidUpdate(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let percentage = percentForGesture(gestureRecognizer)
        switch gestureRecognizer.state {
        case .began:
            // The Began state is handled by AAPLSlideTransitionDelegate.  In
            // response to the gesture recognizer transitioning to this state,
            // it will trigger the transition.
            break
        case .changed:
            // -percentForGesture returns -1.f if the current position of the
            // touch along the horizontal axis has crossed over the initial
            // position.
            if percentage < 0 {
                cancelWithDelegate(percentComplete: percentage)
            } else {
                updateWithDelegate(percent: percentage)
            }
        case .ended:
            if percentage >= percentToFinish {
                finishWithDelegate(percentComplete: percentage)
            } else {
                cancelWithDelegate(percentComplete: percentage)
            }
        default:
            cancelWithDelegate(percentComplete: percentage)
        }
    }
    
}

private extension TabBarInteractiveAnimator {
    
    func cancelWithDelegate(percentComplete: CGFloat) {
        cancel()
        
        // Need to remove our action from the gesture recognizer to
        // ensure it will not be called again before deallocation.
        gestureRecognizer.removeTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
        
        guard let fromVC = transitionContext?.viewController(forKey: .from),
            let toVC = transitionContext?.viewController(forKey: .to)
            else { return }
        delegate?.tabBarInteractiveAnimator(
            self,
            fromVC: fromVC,
            toVC: toVC,
            cancelWithDuration: Double(duration * (1 - percentComplete)),
            curve: completionCurve
        )
    }
    
    func finishWithDelegate(percentComplete: CGFloat) {
        finish()
        
        guard let fromVC = transitionContext?.viewController(forKey: .from),
            let toVC = transitionContext?.viewController(forKey: .to)
            else { return }
        delegate?.tabBarInteractiveAnimator(
            self,
            fromVC: fromVC,
            toVC: toVC,
            finishWithDuration: Double(duration * (1 - percentComplete)),
            curve: completionCurve
        )
    }
    
    func updateWithDelegate(percent: CGFloat) {
        update(percent)
        
        guard let fromVC = transitionContext?.viewController(forKey: .from),
            let toVC = transitionContext?.viewController(forKey: .to)
            else { return }
        let percentApproximated = min(max(0, percent), 1)
        delegate?.tabBarInteractiveAnimator(
            self,
            fromVC: fromVC,
            toVC: toVC,
            updateWithPercent: percentApproximated
        )
    }
    
}
