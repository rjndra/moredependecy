//
//  AlamofireDataRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import Alamofire
import ObjectMapper

struct AlamofireDataRequestModel {
    var url: URLConvertible
    var method: HTTPMethod = .get
    var parameters: Parameters? = nil
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: HTTPHeaders? = nil
    var requiresAuthorization: Bool = true
}

class AlamofireDataRequest<T: Mappable, K: Mappable> : AlamofireDataRequestProtocol {
    
    typealias RequestDataType = AlamofireDataRequestModel
    
    typealias SuccessResponseType = T
    
    typealias ErrorResponseType = K
    
    typealias FailureResponseType = String
    
    func makeRequest(from data: AlamofireDataRequestModel, requestState: APIRequestState) throws -> DataRequest {
        
        var headers = allHeaders(with: data.headers, session: requestState.session)
        if data.requiresAuthorization {
            if let token = AuthCache.AcessToken.get(), let token_type = AuthCache.AccessTokenType.get() {
                headers.add(name: "Authorization", value: "\(token_type) \(token)")
            }
        }
        
        let request = requestState.session.request(data.url, method: data.method, parameters: data.parameters, encoding: data.encoding, headers: headers)
        
        return request
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

extension APIManager {
    
    open func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        requiresAuthorization: Bool = true)
        -> DataRequest {
            
            let newUrl: URLConvertible = url
            
            var headers = allHeaders(with: headers, session: self.state.session)
            if requiresAuthorization {
                if let token = AuthCache.AcessToken.get(), let token_type = AuthCache.AccessTokenType.get() {
                    headers.add(name: "Authorization", value: "\(token_type) \(token)")
                }
            }
            
            return self.state.session.request(newUrl, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
    
}
