//
//  UIFont+Extension.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import UIKit


extension UILabel {
    func font(_ font: UIFont) {
        if #available(iOS 11.0, *) {
            self.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        } else {
            // Fallback on earlier versions
            self.font = font
        }
        self.adjustsFontForContentSizeCategory = true
    }
}

extension UIButton {
    func font(_ font: UIFont) {
        if #available(iOS 11.0, *) {
            self.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        } else {
            // Fallback on earlier versions
            self.titleLabel?.font = font
        }
        self.titleLabel?.adjustsFontForContentSizeCategory = true
    }
}

extension UITextField {
    func font(_ font: UIFont) {
        if #available(iOS 11.0, *) {
            self.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        } else {
            // Fallback on earlier versions
            self.font = font
        }
        self.adjustsFontForContentSizeCategory = true
    }
}

extension UITextView {
    func font(_ font: UIFont) {
        if #available(iOS 11.0, *) {
            self.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        } else {
            // Fallback on earlier versions
            self.font = font
        }
        self.adjustsFontForContentSizeCategory = true
    }
}
