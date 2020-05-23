//
//  String+App Version.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 23.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

extension String {
    
    func versionCompare(_ comparingVersion: String, versionDelimiter: String = ",") -> ComparisonResult {

        var versionComponents = self.components(separatedBy: versionDelimiter)
        var otherVersionComponents = comparingVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count

        if zeroDiff == 0 { // Same format, compare normally
            return self.compare(comparingVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff))
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros)
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            
            let formattedCurrentVersion = versionComponents.joined(separator: versionDelimiter)
            let formattedComparingVersion = otherVersionComponents.joined(separator: versionDelimiter)
            
            return formattedCurrentVersion.compare(formattedComparingVersion, options: .numeric) // <6>
        }
    }
    
}
