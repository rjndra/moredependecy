//
//  LoginViewController.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import UIKit
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class LoginViewController: UIViewController {
    
    @IBOutlet weak private var emailTextField: MDCOutlinedTextField!
    @IBOutlet weak private var passwordTextField: MDCOutlinedTextField!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var forgotPasswordButton: UIButton!
    @IBOutlet weak private var backButton: UIButton!
    
    private var allTextFields = [MDCOutlinedTextField]()
    
    private var isPasswordVisible: Bool = false
    private var viewModel = Login.ViewModel()
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - IBActions
    @IBAction private func backAction(_ sender: UIButton) {
        
    }
    
    @IBAction func forgotAction(_ sender: UIButton) {
        
    }
    
    @IBAction func downloadVideo(_ sender: UIButton) {
        AuthenticationWorker().downloadAndSaveVideo { progress in
            print("Progress: \(progress)")
        } success: { (localPath) in
            print(("local saved path : \(localPath)"))
        } failure: { (error) in
            print(error)
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        if validate() {
          // Call login api
            guard let requestModel = self.viewModel.requestModel else {
                print("Incomplete")
                return
            }
            self.login(with: requestModel)
        } else {
            self.viewModel.requestModel = nil
        }
    }
    
    // MARK: - View Setups
    private func setupViews() {
        
        self.hideKeyboardWhenTappedAround()
        self.emailTextField.label.text = "Email"
        self.emailTextField.keyboardType = .emailAddress
        self.emailTextField.delegate = self
    
        self.passwordTextField.label.text = "password"
        self.passwordTextField.isSecureTextEntry = true
//        let passwordTrailingView = PasswordTrailingView(frame: CGRect(x: 0, y: 0, width: 24.0, height: 24.0))
//        self.passwordTextField.isSecureTextEntry = true
//        self.passwordTextField.trailingViewMode = .always
//        passwordTrailingView.isSecureEntry = { (value) in
//            self.passwordTextField.isSecureTextEntry = value
//        }
//        self.passwordTextField.trailingView = passwordTrailingView
        self.passwordTextField.delegate = self
                
        self.loginButton.layer.cornerRadius = 5.0
        self.loginButton.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.masksToBounds = true
        
    }
    
    private func accessLoginButton(with action:Bool){
        self.loginButton.isUserInteractionEnabled = action
    }
    
    // MARK: - Helpers
    private func validate() -> Bool {
        guard var email = emailTextField.text, email != "" else {
            self.emailTextField.setErrorText("This field is required")
            emailTextField.trailingViewMode = .unlessEditing
            return false
        }
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
//        if !email.isEmail {
//            self.emailTextField.setErrorText("Invalid Email")
//            emailTextField.trailingViewMode = .unlessEditing
//            return false
//        }
        
        guard var password = passwordTextField.text, password != "" else {
            self.passwordTextField.setErrorText("This field is required")
            return false
        }
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
                
        self.viewModel.requestModel = Login.Request(email: email, password: password)
        
        return true
        
    }
    
    // MARK: - Network Helper Start
    
    func login(with request: Login.Request) {
        
        AuthenticationWorker().login(request: request) { (response) in
            if response {
                print("Login Success")
            } else {
                print("Device registration required")
            }
        } failure: { (errorMessage) in
            print(errorMessage)
        }
    }
    // MARK: Network Helper End
    
}

// MARK: -
extension LoginViewController: UITextFieldDelegate {
//    func textField(_ textField: UITextField,
//                   shouldChangeCharactersIn range: NSRange,
//                   replacementString string: String) -> Bool {
//        if textField == emailTextField {
//            self.emailTextField.setErrorText(nil)
//            emailTextField.trailingViewMode = .never
//        }
//        if textField == passwordTextField {
//            self.passwordTextField.setErrorText(nil)
//        }
//
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        let index = textField.tag
//        if index + 1 < allTextFields.count {
//            let nextField = allTextFields[index + 1]
//            nextField.becomeFirstResponder()
//        } else {
//            textField.resignFirstResponder()
//        }
//
//        return false
//    }
    
}
