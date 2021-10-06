//
//  UIView+Extensions.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import UIKit

extension UIView {
    
    func hideKeyboardWhenTappedAround() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
        self.endEditing(true)
    }
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
