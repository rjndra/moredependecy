//
//  APIDataResponse.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import ObjectMapper

class APIDataResponse<T:Mappable>: APIResponse {
    var data: T?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}

