//
//  TabBarInteractiveAnimator.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 20.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

protocol TabBarInteractiveAnimatorDelegate: class {
    func swipeInteractorCancel(fromVC: UIViewController, toVC: UIViewController, duration: TimeInterval)
    func swipeInteractorFinish(fromVC: UIViewController, toVC: UIViewController, duration: TimeInterval)
    func swipeInteractorUpdate(fromVC: UIViewController, toVC: UIViewController, percentage: CGFloat)
}

final class TabBarInteractiveAnimator: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Private
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private let gestureRecognizer: UIPanGestureRecognizer

    private var initialLocationInContainerView = CGPoint()
    private var initialTranslationInContainerView = CGPoint()
    
    weak var delegate: TabBarInteractiveAnimatorDelegate?
    
    init(
        gestureRecognizer: UIPanGestureRecognizer,
        delegate: TabBarInteractiveAnimatorDelegate?
    ) {
        self.gestureRecognizer = gestureRecognizer

        super.init()
        
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
        initialLocationInContainerView = gestureRecognizer.location(in: transitionContext.containerView)
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
        let transitionContainerView = transitionContext?.containerView
        
        let translationInContainerView = gesture.translation(in: transitionContainerView)
        
        // If the direction of the current touch along the horizontal axis does not
        // match the initial direction, then the current touch position along
        // the horizontal axis has crossed over the initial position.
        if translationInContainerView.x > 0 && initialTranslationInContainerView.x < 0 ||
            translationInContainerView.x < 0 && initialTranslationInContainerView.x > 0 {
            return -1
        }
        
        // Figure out what percentage we've traveled.
        return abs(translationInContainerView.x) / (transitionContainerView?.bounds ?? CGRect()).width
    }
    
    @objc func gestureRecognizeDidUpdate(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let percentage = percentForGesture(gestureRecognizer)
        print(percentage)
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
                cancelWithDelegate(percentage: percentage)
            } else {
                updateWithDelegate(percentage: percentage)
            }
        case .ended:
            if percentage >= 0.5 {
                finishWithDelegate(percentage: percentage)
            } else {
                cancelWithDelegate(percentage: percentage)
            }
        default:
            cancelWithDelegate(percentage: percentage)
        }
    }
    
    func cancelWithDelegate(percentage: CGFloat) {
        print(duration, completionSpeed, percentage)
        cancel()
        
        // Need to remove our action from the gesture recognizer to
        // ensure it will not be called again before deallocation.
        gestureRecognizer.removeTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
        
        guard let fromVC = transitionContext?.viewController(forKey: .from),
            let toVC = transitionContext?.viewController(forKey: .to)
            else { return }
        
        delegate?.swipeInteractorCancel(fromVC: fromVC, toVC: toVC, duration: Double(completionSpeed * (1 - percentage)))
    }
    
    func finishWithDelegate(percentage: CGFloat) {
        print(duration, completionSpeed, percentage)
        finish()
        
        guard let fromVC = transitionContext?.viewController(forKey: .from),
            let toVC = transitionContext?.viewController(forKey: .to)
            else { return }
        delegate?.swipeInteractorFinish(fromVC: fromVC, toVC: toVC, duration: Double(completionSpeed * (1 - percentage)))
    }
    
    func updateWithDelegate(percentage: CGFloat) {
        update(percentage)
        
        guard let fromVC = transitionContext?.viewController(forKey: .from),
            let toVC = transitionContext?.viewController(forKey: .to)
            else { return }
        delegate?.swipeInteractorUpdate(fromVC: fromVC, toVC: toVC, percentage: percentage)
    }
    
}
