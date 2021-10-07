//
//  APIManagerUploadRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Alamofire

struct AlamofireUploadRequestModel {
    var url: URLConvertible
    var method: HTTPMethod = .post
    var data: Data?
    var dataKey:String = "image"
    var parameters: Parameters? = nil
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: HTTPHeaders? = nil
    var requiresAuthorization: Bool = true
}

extension APIManager {
    
    open func dataUpload(
        _ url: URLConvertible,
        method: HTTPMethod = .post,
        data: Data?,
        dataKey:String = "image",
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        requiresAuthorization: Bool = true) -> UploadRequest {
        
        
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
        
        let uploadRequest = self.state.session.upload(multipartFormData: { (multipartFormData) in
            
            if let params = parameters {
                for (key, value) in params {
                    if let temp = value as? String {
                        multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    }
                }
            }
            let dateTimeStamp = Int(Date().timeIntervalSince1970)
            let name = "image"+"_\(dateTimeStamp)"
            if let val = data {
                let array = [UInt8](val)
                switch (array[0]) {
                case 0xFF:
                    multipartFormData.append(val, withName: dataKey, fileName: name+".jpeg", mimeType: "image/jpeg;base64")
                case 0x89:
                    multipartFormData.append(val, withName: dataKey, fileName: name+".png", mimeType: "image/png;base64")
                case 0x47:
                    multipartFormData.append(val, withName: dataKey, fileName: name+".gif", mimeType: "image/gif;base64")
                case 0x49, 0x4D :
                    multipartFormData.append(val, withName: dataKey, fileName: name+".tiff", mimeType: "image/tiff;base64")
                default:
                    break
                }
            }
        }, to: url, method: method, headers: headers)
        
        return uploadRequest
    }
}

