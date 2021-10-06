//
//  UIImages.swift
//  More Dependency
//
//  Created by CTN on 10/5/21.
//

import UIKit

enum Icons:String {
    case dropDownTrailingImage = "down_arrow_pdf"
    case emialTrailingImage = "ic_error_outline"
    case passwordVisibilityOffImage = "ic_eye_visibility_off"
    case passwordVisibilityOnImage = "ic_eye_visibility_on"
    case clearImage = "ic_clear"
    
    func image() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}
