import UIKit

class BaseScrollDelegateViewController: UIViewController, TabBarChildViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private weak var tableView: UITableView!
    
    weak var scrollDelegate: UIScrollViewDelegate!
    var additionalTopContentInset: CGFloat = 0 {
        didSet {
            tableView?.contentInset.top = additionalTopContentInset
            tableView?.verticalScrollIndicatorInsets.top = additionalTopContentInset
        }
    }
    private var restoredScrollViewContentOffset = CGPoint.zero
    func updateScrollContentOffsetIfNeeded(to y: CGFloat, animated: Bool) {
        let currentContentOffsetY = tableView?.contentOffset.y ?? 0
        
        // TODO: - remove hardcoded values
        if currentContentOffsetY == y || (currentContentOffsetY > y && y >= 0) {
            return
        } else {
            let contentOffset = CGPoint(x: 0, y: y)
            restoredScrollViewContentOffset = contentOffset
            tableView?.setContentOffset(contentOffset, animated: animated)
        }
        
//        if currentContentOffsetY < y && y >= 0 {
//            let contentOffset = CGPoint(x: 0, y: y)
//            restoredScrollViewContentOffset = contentOffset
//            tableView?.setContentOffset(contentOffset, animated: animated)
//        } else if currentContentOffsetY > y && y >= 0 {
//            return print("\(currentContentOffsetY) > \(y) && \(y) >= 0")
//        } else if currentContentOffsetY >= 0 && y < 0 {
//            let contentOffset = CGPoint(x: 0, y: y)
//            restoredScrollViewContentOffset = contentOffset
//            tableView?.setContentOffset(contentOffset, animated: animated)
//        } else {
//            let contentOffset = CGPoint(x: 0, y: y)
//            restoredScrollViewContentOffset = contentOffset
//            tableView?.setContentOffset(contentOffset, animated: animated)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = additionalTopContentInset
        tableView.contentOffset = restoredScrollViewContentOffset
        tableView.verticalScrollIndicatorInsets.top = additionalTopContentInset
        tableView.dataSource = self
        tableView.delegate = self
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = indexPath.description
        return cell
    }
    
}

final class ViewController0: BaseScrollDelegateViewController {


}

final class ViewController1: BaseScrollDelegateViewController {

    

}

final class ViewController2: UIViewController {

    

}










class KeyboardView: UIView {

    // MARK: Properties

    /// 1
    private(set) lazy var keyboardHeightConstraint = keyboardLayoutGuide.heightAnchor.constraint(equalToConstant: 0)

    /// 2
    let keyboardLayoutGuide = UILayoutGuide()

    // MARK: Initializer

    init() {
        /// 3
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white

        /// 4
        addLayoutGuide(keyboardLayoutGuide)
        NSLayoutConstraint.activate([
            keyboardHeightConstraint,
            keyboardLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
 
    /// 5
    @available(*, unavailable, message: "Use init() method instead.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Overrides

    /// 6
    override static var requiresConstraintBasedLayout: Bool {
        true
    }
}

class KeyboardViewController<CustomView: KeyboardView>: UIViewController {

    // MARK: Properties

    /// 1
    var automaticallyAdjustKeyboardLayoutGuide = false {
        willSet {
            newValue ? registerForKeyboardNotifications() : stopObservingKeyboardNotifications()
        }
    }

    /// 2
    let customView: CustomView

    // MARK: Initializer

    /// 3
    init(view: CustomView) {
        customView = view
        customView.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
    }

    /// 4
    @available(*, unavailable, message: "Use init() method instead.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 5
    deinit {
        stopObservingKeyboardNotifications()
    }

    // MARK: Overrides

    /// 6
    override func loadView() {
        super.loadView()

        view.addSubview(customView)
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: view.topAnchor),
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private extension Notification {

    var keyboardAnimationDuration: TimeInterval? {
        (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }

    var keyboardRect: CGRect? {
        userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    }
}

private extension KeyboardViewController {

    func registerForKeyboardNotifications() {
        /// 1
        let center = NotificationCenter.default

        /// 2
        center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else {
                return
            }
            /// 3
            if self.automaticallyAdjustKeyboardLayoutGuide {
                let offset = notification.keyboardRect?.height ?? 0
                let animationDuration = notification.keyboardAnimationDuration ?? 0.25
                self.adjustKeyboardHeightConstraint(byOffset: offset, animationDuration: animationDuration)
            }
        }
        /// 4
        center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else {
                return
            }
            /// 5
            if self.automaticallyAdjustKeyboardLayoutGuide {
                let animationDuration = notification.keyboardAnimationDuration ?? 0.25
                self.adjustKeyboardHeightConstraint(byOffset: 0, animationDuration: animationDuration)
            }
        }
        /// 6
        center.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else {
                return
            }
            /// 7
            if self.automaticallyAdjustKeyboardLayoutGuide, let offset = notification.keyboardRect?.height {
                let animationDuration = notification.keyboardAnimationDuration ?? 0.25
                self.adjustKeyboardHeightConstraint(byOffset: offset, animationDuration: animationDuration)
            }
        }
    }

    func stopObservingKeyboardNotifications() {
        /// 8
        [
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardWillChangeFrameNotification
        ].forEach {
            NotificationCenter.default.removeObserver(self, name: $0, object: nil)
        }
    }

    func adjustKeyboardHeightConstraint(byOffset offset: CGFloat, animationDuration: TimeInterval) {
        /// 9
        customView.keyboardHeightConstraint.constant = offset
        UIView.animate(withDuration: animationDuration) {
            self.customView.layoutIfNeeded()
        }
    }
}
