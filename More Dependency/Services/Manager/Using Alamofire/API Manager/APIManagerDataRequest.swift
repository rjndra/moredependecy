//
//  APIManagerDataRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Alamofire

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
