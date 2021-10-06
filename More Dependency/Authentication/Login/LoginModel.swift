//
//  LoginModel.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import ObjectMapper

enum Login {
    
    struct ViewModel {
        var requestModel: Login.Request?
    }
    
    struct Request {
        var email:String
        var password:String
        var userType:String = "M"
        var deviceid:String? = FirebaseService().getMessageToken() ?? deviceID 
        
        func body() -> Dictionary<String,String> {
            
            var params:Dictionary<String,String> = [
                "email": email,
                "password" : password,
                "user_type" :userType
            ]
            if let deviceID = self.deviceid {
                params["device_id"] = deviceID
            }
            
            return params
        }
        
        
        func bodyk() -> Dictionary<String,String> {
            return [
                "id": email,
                "password" : password
            ]
        }
    }
    
    class Response: APIResponse {
        
        var type:String?
        var userTypes:[String]?
        var code:String?
        var agent:Agent?
        var group:Group?
        var member:Member?
        var user:User?
        var token_type:String?
        var access_token:String?
        var expires_at:String?
        var isPasswordStrong:Bool?
        
        override func mapping(map: Map) {
            super.mapping(map: map)
            code <- map["code"]
            type <- map["type"]
            userTypes <- map["user_types"]
            agent <- map["agent"]
            group <- map["group"]
            member <- map["member"]
            user <- map["user"]
            token_type <- map["token_type"]
            access_token <- map["access_token"]
            expires_at <- map["expires_at"]
            isPasswordStrong <- map["is_password_strong"]
        }
    }
    
    struct Agent: Mappable {
        var id:Int?
        var code:String?
        var status:String?
        var isAdmin:Bool = false
        var isRoot:Bool = false
        
        init?(map: Map) {}
        mutating func mapping(map: Map) {
            id <- map["agent_id"]
            code <- map["agent_code"]
            status <- map["status"]
            isAdmin <- map["is_admin"]
            isRoot <- map["is_root"]
        }
    }
    
    struct Group: Mappable {
        var id:Int?
        
        init?(map: Map) {}
        mutating func mapping(map: Map) {
            id <- map["group_id"]
        }
    }
    
    struct Member: Mappable {
        var id:Int?
        
        init?(map: Map) {}
        mutating func mapping(map: Map) {
            id <- map["member_id"]
        }
    }
    
    struct User:Mappable {
        
        var id:Int?
        var email:String?
        var name:String?
        var phone:String?
        var image:String?
        var deviceID:String?
        var device_verified:Bool?
        var device_Verified_at:String?
        var device_token:String?
        
        init?(map: Map) {}
        mutating func mapping(map: Map) {
            id <- map["id"]
            email <- map["email"]
            name <- map["name"]
            phone <- map["phone"]
            image <- map["image"]
            deviceID <- map["deviceid"]
            device_verified <- map["device_verified"]
            device_Verified_at <- map["device_verified_at"]
            device_token <- map["device_token"]
        }
    }
    
    class Error: APIResponse {
        
        var user:User?
        
        override func mapping(map: Map) {
            super.mapping(map: map)
            user <- map["user"]
        }
    }
}
