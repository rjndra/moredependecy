//
//  Router.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import UIKit

struct Router {
    
    func setRootLogin() {
        let vc = LoginViewController()
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
}
