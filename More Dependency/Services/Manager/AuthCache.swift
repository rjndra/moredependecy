//
//  AuthCache.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation

extension UserDefaultKey {
    
    static let tokenType = UserDefaultKey(key: "token_type")
    static let accessToken = UserDefaultKey(key: "access_token")
    
}

//TODO: Move to keychain
class AuthCache {
    
    
    /// AccessToken
    class AcessToken {
        class func save(token: String?) {
            UserDefaultKey.accessToken.set(value: token)
        }
        
        class func get() -> String? {
            let authToken:String? = UserDefaultKey.accessToken.value()
            return authToken
        }
        
        class func remove() {
            UserDefaultKey.accessToken.remove()
        }
    }
    
    /// Token Type
    class AccessTokenType {
        
        class func save(token: String?) {
            UserDefaultKey.tokenType.set(value: token)
        }
        
        class func get() -> String? {
            let authToken:String? = UserDefaultKey.tokenType.value()
            return authToken
        }
        
        class func remove() {
            UserDefaultKey.tokenType.remove()
        }
    }
}
