import UIKit

@IBDesignable class DesignableSegmentedControl: UISegmentedControl {
    
    @IBInspectable var selectedColor: UIColor = .black
    @IBInspectable var normalColor: UIColor = .white
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor = normalColor
        }
        
        setTitleTextAttributes([.foregroundColor: selectedColor], for: .selected)
        setTitleTextAttributes([.foregroundColor: normalColor], for: .normal)
    }
    
}
