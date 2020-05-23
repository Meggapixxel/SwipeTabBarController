import UIKit

protocol TabBarChildViewController: UIViewController, UIScrollViewDelegate {
    var scrollDelegate: UIScrollViewDelegate! { get set }
    var additionalTopContentInset: CGFloat { get set }
    func updateScrollContentOffsetIfNeeded(to y: CGFloat, animated: Bool)
}
