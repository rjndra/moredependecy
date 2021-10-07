//
//  UploadDataRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation
import ObjectMapper

struct UploadRequestModel {
    var url: String
    var method: String = "POST"
    var dataKey:String = "image"
    var data: Data?
    var parameters: [String:Any]? = nil
    var encoding:JSONSerialization.WritingOptions = []
    var headers: [String:String]? = nil
    var destination: String? = nil
    var requiresAuthorization: Bool = true
}

class UploadDataRequest<T: Mappable, K: Mappable> : UploadRequestProtocol {
    
    typealias RequestDataType = UploadRequestModel
    
    let boundary = "Boundary-\(UUID().uuidString)"
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest {
        
        var urlRequest = URLRequest(url: URL(string: data.url)!)
        urlRequest.httpMethod = data.method
        urlRequest.updateHeader()
        if let header = data.headers {
            for (index,value) in header {
                urlRequest.setValue(value, forHTTPHeaderField: index)
            }
        }
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if data.requiresAuthorization {
            if let token = AuthCache.AcessToken.get(), let token_type = AuthCache.AccessTokenType.get() {
                urlRequest.addValue("\(token_type) \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        let httpBody = NSMutableData()
        if let formFields = data.parameters {
            for (key, value) in formFields {
                if let temp = value as? String {
                    httpBody.appendString( UploadRequestHelper().convertFormField(named: key, value: temp, using: boundary))
                }
                else if let temp = value as? Int {
                    httpBody.appendString(UploadRequestHelper().convertFormField(named: key, value: "\(temp)", using: boundary))
                }
                else if let temp = value as? [String] {
                    let arrData =  try? JSONSerialization.data(withJSONObject: temp, options: .prettyPrinted)
                    if let data = arrData {
                        httpBody.append(UploadRequestHelper().convertFileFieldData(named: key, value: data, using: boundary))
                    }
                }
            }
        }

        if let fileData = data.data {
            httpBody.append(UploadRequestHelper().convertFileData(fieldName: data.dataKey,
                                            fileName: "Image",
                                            fileData: fileData,
                                            using: boundary))
        }
        
        httpBody.appendString("--\(boundary)--")

        urlRequest.httpBody = httpBody as Data

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


