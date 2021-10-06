//
//  UserDefaultsManager.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation

struct UserDefaultKey {
    let key: String
    
    func set(value: Any?) {
        UserDefaults.standard.set(value, forKey: self.key)
    }
    
    func remove() {
        UserDefaults.standard.removeObject(forKey: self.key)
    }
    
    func value<T: Any>() -> T? {
        return UserDefaults.standard.value(forKey: self.key) as? T
    }
    
}
