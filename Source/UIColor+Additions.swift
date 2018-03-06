//
//  UIColor+Additions.swift
//  Refreshie
//
//  Created by vladislav klimenko on 06/03/2018.
//  Copyright © 2018 Wooden Co. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func bma_color(rgb: Int) -> UIColor {
        return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0xFF00) >> 8) / 255.0, blue: CGFloat((rgb & 0xFF)) / 255.0, alpha: 1.0)
    }
    
}
