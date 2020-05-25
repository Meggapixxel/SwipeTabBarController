//
//  UIView+Snapshot.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 24.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import UIKit

extension UIView {
    
    enum SnapshotOptions {
        case layer, withSublayers
    }
    
    func snapshotLayerImage(cgRect: CGRect) -> UIImage {
        return UIGraphicsImageRenderer(bounds: cgRect).image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func snapshotViewImage(cgRect: CGRect) -> UIImage {
        return UIGraphicsImageRenderer(bounds: cgRect).image { rendererContext in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    func snapshotLayerImageView(cgRect: CGRect) -> UIImageView {
        UIImageView(image: snapshotLayerImage(cgRect: cgRect))
    }
    
    func snapshotViewImageView(cgRect: CGRect) -> UIImageView {
        UIImageView(image: snapshotViewImage(cgRect: cgRect))
    }
    
}

extension UIView {

    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes. Defaults to `true`.
    ///
    /// - Returns: The `UIImage` snapshot.

    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage? {
        if #available(iOS 11, *) {
            return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
                drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
            let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            // if no `rect` provided, return image of whole view

            guard let image = wholeImage, let rect = rect else { return wholeImage }

            // otherwise, grab specified `rect` of image

            guard let cgImage = image.cgImage?.cropping(to: rect * image.scale) else { return nil }
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
        }
    }
}
extension CGRect {
    static func * (lhs: CGRect, rhs: CGFloat) -> CGRect {
        return CGRect(x: lhs.minX * rhs, y: lhs.minY * rhs, width: lhs.width * rhs, height: lhs.height * rhs)
    }
}
