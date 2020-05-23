import UIKit

extension UIImage {

    func applying(cornerRadius: CGFloat) -> UIImage {
        let imageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous

        return UIGraphicsImageRenderer(size: imageView.bounds.size).image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
}
