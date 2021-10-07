//
//  NormalDataRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation
import ObjectMapper

struct DataRequestModel {
    var url: String
    var method: String = "GET"
    var parameters: [String:Any]? = nil
    var encoding:JSONSerialization.WritingOptions = []
    var headers: [String:String]? = nil
    var requiresAuthorization: Bool = true
}

class NormalDataRequest<T: Mappable, K: Mappable> : DataRequestProtocol {
    
    typealias RequestDataType = DataRequestModel
    
    typealias SuccessResponseType = T
    
    typealias ErrorResponseType = K
    
    typealias FailureResponseType = String
    
    func makeRequest(from data: DataRequestModel, requestState: APIRequestState) throws -> URLRequest {
        
        var urlRequest = URLRequest(url: URL(string: data.url)!)
        urlRequest.httpMethod = data.method
        
        if let params = data.parameters {
            let body = try? JSONSerialization.data(withJSONObject: params, options: data.encoding)
            urlRequest.httpBody = body
        }
        
        urlRequest.updateHeader()
        if let header = data.headers {
            for (index,value) in header {
                urlRequest.setValue(value, forHTTPHeaderField: index)
            }
        }
        if urlRequest.headers["Content-Type"] == nil {
            urlRequest.headers.update(.contentType("application/json"))
        }
        
        if data.requiresAuthorization {
            if let token = AuthCache.AcessToken.get(), let token_type = AuthCache.AccessTokenType.get() {
                urlRequest.addValue("\(token_type) \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return urlRequest
    }
    
    func parseSuccessResponse(data: Any) throws -> T {
        let response:T  = try NetworkUtilities().parseResponse(for: data)
        return response
    }
    
    func parseErrorResponse(data: Any) throws -> K {
        let response:K  = try NetworkUtilities().parseResponse(for: data)
        return response
    }
    
    func parseFailureResponse(status: Int, data: Any) -> String {
        let response = NetworkUtilities().parseResponseError(status: status, data: data)
        return response
    }
}



