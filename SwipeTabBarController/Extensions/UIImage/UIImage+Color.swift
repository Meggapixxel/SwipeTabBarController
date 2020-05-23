import UIKit

extension UIImage {
    
    static func from(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
            color.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }

}
