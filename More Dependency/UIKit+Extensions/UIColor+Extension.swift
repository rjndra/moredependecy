//
//  UIColor+Extension.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import UIKit

extension UIColor {
    
    convenience init(_ hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
