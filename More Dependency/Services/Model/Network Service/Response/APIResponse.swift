//
//  APIResponse.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import ObjectMapper

class APIResponse: Mappable {
    
    var statusCode:Int?
    var status:String?
    var message:String?
    var formMessage:String?
    
    init() { }
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        status <- map["status"]
        statusCode <- map["statusCode"]
        message <- map["message"]
    }
}
