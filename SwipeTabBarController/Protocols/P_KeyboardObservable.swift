import UIKit

struct KeyboardObservableOptions: OptionSet {
    
    let rawValue: Int
    
    static let willShow        = KeyboardObservableOptions(rawValue: 1 << 0)
    static let willHide        = KeyboardObservableOptions(rawValue: 1 << 1)
    static let willChangeFrame = KeyboardObservableOptions(rawValue: 1 << 2)
    
    static let all: KeyboardObservableOptions = [.willShow, .willHide, .willChangeFrame]
    static let showHide: KeyboardObservableOptions = [.willShow, .willHide]

}

enum KeyboardObservableAction {
    
    case willShow(height: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions)
    case willHide(duration: TimeInterval, options: UIView.AnimationOptions)
    case willChangeFrame(height: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions)
    
    var height: CGFloat {
        switch self {
        case .willShow(let height, _, _):
            return height
        case .willHide(_, _):
            return 0
        case .willChangeFrame(let height, _, _):
            return height
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .willShow(_, let duration, _):
            return duration
        case .willHide(let duration, _):
            return duration
        case .willChangeFrame(_, let duration, _):
            return duration
        }
    }
    var options: UIView.AnimationOptions {
        switch self {
        case .willShow(_, _, let options):
            return options
        case .willHide(_, let options):
            return options
        case .willChangeFrame(_, _, let options):
            return options
        }
    }
    
}

protocol P_KeyboardObservable: NSObject {
    
    var keyboardObserveOptions: KeyboardObservableOptions { get }
    func keyboardObservable(action: KeyboardObservableAction)
    
}
extension P_KeyboardObservable {
    
    func beginKeyboardObserving() {
        endKeyboardObserving()
        
        let options = keyboardObserveOptions
        
        let center = NotificationCenter.default
        if options.contains(.willShow) {
            center.addObserver(self, selector: #selector(willShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        if options.contains(.willHide) {
            center.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        if options.contains(.willChangeFrame) {
            center.addObserver(self, selector: #selector(willChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
    }
    
    func endKeyboardObserving() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        center.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        center.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
}
extension P_KeyboardObservable where Self: UIViewController {
    
    func keyboardObservable(action: KeyboardObservableAction) {
        UIView.animate(
            withDuration: action.duration,
            delay: 0,
            options: action.options,
            animations: {
                self.additionalSafeAreaInsets.bottom = action.height - (self.tabBarController?.tabBar.frame.height ?? 0)
                self.view.layoutIfNeeded()
            }
        )
    }
    
}

protocol P_KeyboardObservableWithDismiss: P_KeyboardObservable {
    var keyboardDismissGestureRecognizer: UIGestureRecognizer { get } // must be stored because must be removed on keyboard hide
    var keyboardDismissTargetView: UIView { get }
}
fileprivate extension P_KeyboardObservableWithDismiss {
    
    func addGestureRecognizer() {
        let gestureRecognizer = keyboardDismissGestureRecognizer
        let view = keyboardDismissTargetView
        gestureRecognizer.addTarget(view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    func removeGestureRecognizer() {
        let gestureRecognizer = keyboardDismissGestureRecognizer
        let view = keyboardDismissTargetView
        view.removeGestureRecognizer(gestureRecognizer)
    }
    
}
extension P_KeyboardObservableWithDismiss where Self: UIViewController {
    
    var keyboardDismissTargetView: UIView { view }
    
}


fileprivate extension NSObject {
    
    @objc func willShow(_ notification: Notification) {
        guard let keyboardObservable = self as? P_KeyboardObservable,
            let height = notification.rect?.height,
            let duration = notification.duration,
            let options = notification.options
            else { return }
        
        if let keyboardObservableWithDismiss = self as? P_KeyboardObservableWithDismiss {
            keyboardObservableWithDismiss.addGestureRecognizer()
        }
        
        keyboardObservable.keyboardObservable(action: .willShow(height: height, duration: duration, options: options))
    }
    
    @objc func willHide(_ notification: Notification) {
        guard let keyboardObservable = self as? P_KeyboardObservable,
            let duration = notification.duration,
            let options = notification.options
            else { return }
        
        if let keyboardObservableWithDismiss = self as? P_KeyboardObservableWithDismiss {
            keyboardObservableWithDismiss.removeGestureRecognizer()
        }
        
        keyboardObservable.keyboardObservable(action: .willHide(duration: duration, options: options))
    }
    
    @objc func willChangeFrame(_ notification: Notification) {
        guard let keyboardObservable = self as? P_KeyboardObservable,
            let height = notification.rect?.height,
            let duration = notification.duration,
            let options = notification.options
            else { return }
        keyboardObservable.keyboardObservable(action: .willChangeFrame(height: height, duration: duration, options: options))
    }
    
}

private extension Notification {
    
    var rect: CGRect? { (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue }
    
    var duration: Double? { userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double }
    
    var options: UIView.AnimationOptions? {
        guard let rawValue = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return nil }
        return UIView.AnimationOptions(rawValue: rawValue)
    }
    
}
