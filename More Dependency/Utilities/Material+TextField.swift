//
//  Material+TextField.swift
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

let blueColor: UIColor = UIColor(red: 14.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)
let activeColor: UIColor = UIColor(red: 238.0/255.0, green: 232.0/255.0, blue: 236.0/255.0, alpha: 1.0)
let labelActiveColor: UIColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)

extension MDCOutlinedTextField {
    
    func setup() {
        self.setNormalLabelColor(UIColor(0x808080), for: .normal)
        self.setNormalLabelColor(UIColor(0x808080), for: .editing)
        
        self.setFloatingLabelColor(UIColor(0x808080), for: .normal)
        self.setFloatingLabelColor(UIColor(0x808080), for: .editing)
        
        self.setOutlineColor(UIColor(0xEEE7EC), for: .normal)
        self.setOutlineColor(UIColor(0xEEE7EC), for: .editing)
        self.setOutlineColor(UIColor(0xEEE7EC), for: .disabled)
        
        self.label.font(FontStyle.SFProDisplayRegular.font())
        self.font(FontStyle.SFProDisplayRegular.font(size: 15.0))
        
        self.clearButtonMode = .whileEditing
        
        self.setTextColor(UIColor(0x000E11).withAlphaComponent(0.87), for: .normal)
        self.setTextColor(UIColor(0x000E11), for: .editing)
        
        self.setLeadingAssistiveLabelColor(UIColor.appRed, for: .normal)
        self.backgroundColor = UIColor.white
    }
    
    func setErrorText(_ text:String?) {
        self.leadingAssistiveLabel.text = text
        self.leadingAssistiveLabel.textColor = UIColor.appRed
    }
    
    func validateEmpty() -> Bool {
        if self.text == "" {
            self.setErrorText("This field is required")
            return false
        }
        return true
    }
    
}

extension MDCOutlinedTextArea {
    
    func setup() {
        self.setNormalLabel(UIColor(0x808080), for: .normal)
        self.setNormalLabel(UIColor(0x808080), for: .editing)
        
        self.setFloatingLabel(UIColor(0x808080), for: .normal)
        self.setFloatingLabel(UIColor(0x808080), for: .editing)
        
        self.setOutlineColor(UIColor(0xEEE7EC), for: .normal)
        self.setOutlineColor(UIColor(0xEEE7EC), for: .editing)
        self.setOutlineColor(UIColor(0xEEE7EC), for: .disabled)
        
        self.label.font(FontStyle.SFProDisplayRegular.font())
        self.textView.font(FontStyle.SFProDisplayRegular.font(size: 15.0))
        
        self.leadingAssistiveLabel.font = FontStyle.SFProDisplayRegular.font()
        
        self.setTextColor(UIColor(0x000E11).withAlphaComponent(0.87), for: .normal)
        self.setTextColor(UIColor(0x000E11), for: .editing)
        
        self.setLeadingAssistiveLabel(UIColor.appRed, for: .normal)
        //        self.sizeToFit()
        self.backgroundColor = UIColor.white
    }
    
    func setErrorText(_ text:String?) {
        self.leadingAssistiveLabel.text = text
        self.leadingAssistiveLabel.textColor = UIColor.appRed
    }
    
    func validateEmpty() -> Bool {
        if self.label.text == "" {
            self.setErrorText("This field is required")
            return false
        }
        return true
    }
    
}

class PasswordTrailingView: UIView {
    
    private var isPasswordVisible: Bool = false
    
    var isSecureEntry: ((Bool) -> ())?
    
    private let passwordVisibilityButton: UIButton = {
        var trailingButton = UIButton()
        trailingButton.tintColor = UIColor.appBlue
        trailingButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        trailingButton.addTarget(self, action: #selector(passwordButtonClicked), for: .touchUpInside)
        trailingButton.setImage(Icons.passwordVisibilityOnImage.image(), for:  .normal)
        return trailingButton
    }()
    
    @objc func passwordButtonClicked(_ sender: UIButton) {
        isPasswordVisible = !isPasswordVisible
        let image = isPasswordVisible ? Icons.passwordVisibilityOffImage.image() : Icons.passwordVisibilityOnImage.image()
        self.isSecureEntry?(!isPasswordVisible)
        sender.setImage(image, for:  .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.addSubview(passwordVisibilityButton)
        self.passwordVisibilityButton.center = self.center
        self.passwordVisibilityButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.passwordVisibilityButton.topAnchor.constraint(equalTo: self.topAnchor),
            self.passwordVisibilityButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.passwordVisibilityButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.passwordVisibilityButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        self.passwordVisibilityButton.bringSubviewToFront(self)
    }
    
    public func toogleStateForTrailingButton() {
        self.passwordButtonClicked(self.passwordVisibilityButton)
    }
    
}

