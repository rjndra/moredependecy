//
//  FontStyle.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import UIKit

enum FontStyle:String {
    case robotoRegular = "Roboto-Regular"
    case robotoBold = "Roboto-Bold"
    case robotoBoldItalic = "Roboto-BoldItalic"
    case robotoMedium = "Roboto-Medium"
    case robotoMediumItalic = "Roboto-MediumItalic"
    case robotoBlack = "Roboto-Black"
    case robotoBlackItalic = "Roboto-BlackItalic"
    case robotoLight = "Roboto-Light"
    case robotoLightItalic = "Roboto-LightItalic"
    case robotoThin = "Roboto-Thin"
    case robotoThinItalic = "Roboto-ThinItalic"
    case SFProDisplayBold = "SFProDisplay-Bold"
    case SFProDisplayRegular = "SFProDisplay-Regular"
    case SFProDisplayMedium = "SFProDisplay-Medium"
    case SFProDisplaySemiBold = "SFProDisplay-Semibold"
    
    func font(size: CGFloat = 12.0) -> UIFont {
        return UIFont(name: self.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
