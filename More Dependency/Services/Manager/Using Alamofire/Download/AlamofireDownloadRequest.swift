//
//  AlamofireDownloadRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation
import Alamofire

struct AlamofireDownloadRequestModel {
    var url: URLConvertible
    var method: HTTPMethod = .get
    var parameters: Parameters? = nil
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: HTTPHeaders? = nil
    var destination:DownloadRequest.Destination? = nil
    var requiresAuthorization: Bool = true
}

class AlamofireDownloadRequest: AlamofireDownloadRequestProtocol {
    
    typealias RequestDataType = AlamofireDownloadRequestModel
    
    func makeRequest(from data: AlamofireDownloadRequestModel, requestState: APIRequestState) throws -> DownloadRequest {
        
        let request = APIManager.shared.download(data.url, destination: data.destination, requiresAuthorization: data.requiresAuthorization)
        
        return request
    }
    
    func parseErrorResponse(status: Int, data: Any) -> String {
        let response = NetworkUtilities().parseResponseError(status: status, data: data)
        return response
    }
}

extension APIManager {
    
    open func download (
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        destination:DownloadRequest.Destination? = nil,
        requiresAuthorization: Bool = true)
        -> DownloadRequest {
            
            var headers = allHeaders(with: headers, session: self.state.session)
            if requiresAuthorization {
                if let token = AuthCache.AcessToken.get(), let token_type = AuthCache.AccessTokenType.get() {
                    headers.add(name: "Authorization", value: "\(token_type) \(token)")
                }
            }
            // Since session manager header automatically not added to request header adding it manually
            if let sessionHeaders = self.state.session.sessionConfiguration.httpAdditionalHeaders {
                for val in sessionHeaders {
                    if let key = val.key as? String, let data = val.value as? String {
                        headers[key] = data
                    }
                }
            }
            return self.state.session.download(url, method: method, parameters: parameters, encoding: encoding, headers: headers, to: destination)
    }
    
}


