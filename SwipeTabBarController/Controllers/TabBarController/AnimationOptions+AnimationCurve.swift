import UIKit

extension UIView.AnimationOptions {
    
    init(curve: UIView.AnimationCurve) {
        switch curve {
        case .easeOut:   self = .curveEaseOut
        case .easeInOut: self = .curveEaseInOut
        case .linear:    self = .curveLinear
        default:         self = .curveEaseIn
        }
    }
    
}
