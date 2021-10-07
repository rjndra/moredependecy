//
//  APIManagerMultipleUploadRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Alamofire


struct AlamofireMultipleUploadRequestModel {
    var url: URLConvertible
    var method: HTTPMethod = .post
    var localPaths: [String]
    var parameters: Parameters? = nil
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: HTTPHeaders? = nil
    var requiresAuthorization: Bool = true
}

extension APIManager {
    
    open func multipleDataUpload(
        _ url: URLConvertible,
        method: HTTPMethod = .post,
        localPaths: [String],
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
                    else if let temp = value as? Int {
                        multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    }
                    else if let temp = value as? [String] {
                        let arrData =  try? JSONSerialization.data(withJSONObject: temp, options: .prettyPrinted)
                        if let data = arrData {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }
            }
            
            for path in localPaths {
                do {
                    let url = URL(fileURLWithPath: path)
                    let data = try Data(contentsOf: url)
                    let dataType = url.pathExtension
                    let fileName = url.pathComponents.last ?? ""
                    let keyName = "file[]"
                    
                    var mimeType = "image/png"
                    switch dataType {
                    case "pdf":
                        mimeType = "application/pdf"
                    case "doc", "docx":
                        mimeType = "application/msword"
                    case "xls", "xlsx":
                        mimeType = "application/vnd.ms-excel"
                    case "ppt", "pptx":
                        mimeType = "application/mspowerpoint"
                    case "png":
                        mimeType = "image/png"
                    case "jpeg", "jpg":
                        mimeType = "image/jpeg;image/jp2"
                    case "csv":
                        mimeType = "application/csv"
                    case "txt":
                        mimeType = "application/txt"
                    default:
                        break
                    }
                    multipartFormData.append(data, withName: keyName, fileName: fileName, mimeType: mimeType)
                } catch let error {
                    print(error.localizedDescription)
                    
                }
                
            }
            
        }, to: url, method: method, headers: headers)
        
        return uploadRequest
    }
}
