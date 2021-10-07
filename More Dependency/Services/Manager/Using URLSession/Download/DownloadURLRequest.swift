//
//  DownloadURLRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/6/21.
//

import Foundation
import ObjectMapper

struct DownloadRequestModel {
    var url: String
    var method: String = "GET"
    var parameters: [String:Any]? = nil
    var encoding:JSONSerialization.WritingOptions = []
    var headers: [String:String]? = nil
    var destination: String? = nil
    var requiresAuthorization: Bool = true
}

class DownloadURLRequest<T: Mappable> : DownloadRequestProtocol {
    
    internal var destination: String?
    
    typealias RequestDataType = DownloadRequestModel
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest {
        
        self.destination = data.destination
        var urlRequest = URLRequest(url: URL(string: data.url)!)
        urlRequest.httpMethod = data.method
        
        if let params = data.parameters {
            let body = try JSONSerialization.data(withJSONObject: params, options: data.encoding)
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
    
    func destinationURL() -> URL? {
        guard let path = self.destination else {
            return nil
        }
        let destinationURL = URL(fileURLWithPath: path, isDirectory: false)
        return destinationURL
    }
    
    func parseErrorResponse(status: Int, data: Any) -> String {
        let response  = NetworkUtilities().parseResponseError(status: status, data: data)
        return response
    }
}
