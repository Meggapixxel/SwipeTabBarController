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
    
}
protocol P_KeyboardObservable: NSObject {
    
    var keyboardObserveOptions: KeyboardObservableOptions { get }
    
    func keyboardObservable(action: KeyboardObservableAction)
    
}

fileprivate extension NSObject {
    
    @objc func willShow(_ notification: Notification) {
        guard let keyboardObservable = self as? P_KeyboardObservable else { return }
        let info = notification.userInfo!
        let height = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let options = UIView.AnimationOptions(rawValue: curve)
        keyboardObservable.keyboardObservable(action: .willShow(height: height, duration: duration, options: options))
    }
    
    @objc func willHide(_ notification: Notification) {
        guard let keyboardObservable = self as? P_KeyboardObservable else { return }
        let info = notification.userInfo!
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let options = UIView.AnimationOptions(rawValue: curve)
        keyboardObservable.keyboardObservable(action: .willHide(duration: duration, options: options))
    }
    
    @objc func willChangeFrame(_ notification: Notification) {
        guard let keyboardObservable = self as? P_KeyboardObservable else { return }
        let info = notification.userInfo!
        let height = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let options = UIView.AnimationOptions(rawValue: curve)
        keyboardObservable.keyboardObservable(action: .willChangeFrame(height: height, duration: duration, options: options))
    }
    
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
