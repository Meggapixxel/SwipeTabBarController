import UIKit

@IBDesignable class UITextFieldRegex: DesignableTextField {
    
    @IBOutlet weak var nextTextField: UITextField?
    @IBInspectable var validationRegex: String? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self, queue: nil) { [weak self] (notification) in
            guard let text = self?.text,
                let validationRegex = self?.validationRegex,
                text.range(of: validationRegex, options: .regularExpression) != nil
                else { return }
            if let nextTextField = self?.nextTextField {
                nextTextField.becomeFirstResponder()
            } else {
                self?.resignFirstResponder()
            }
        }
    }
    
}
