//
//  UploadURLRequest.swift
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

struct MultipleUploadRequestModel {
    var url: String
    var method: String = "POST"
    var dataKey:String = "file"
    var localPaths: [String]
    var parameters: [String:Any]? = nil
    var encoding:JSONSerialization.WritingOptions = []
    var headers: [String:String]? = nil
    var destination: String? = nil
    var requiresAuthorization: Bool = true
}

protocol UploadRequestProtocol {
    associatedtype RequestDataType
    associatedtype SuccessResponseType
    associatedtype ErrorResponseType
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest
    func parseSuccessResponse(data: Any) throws -> SuccessResponseType
    func parseErrorResponse(data: Any) throws -> ErrorResponseType
    func parseFailureResponse(status: Int, data: Any) -> String
}

class UploadURLRequest<T: Mappable, K: Mappable> : UploadRequestProtocol {
    
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
                    httpBody.appendString( UploadURLRequestHelper().convertFormField(named: key, value: temp, using: boundary))
                }
                else if let temp = value as? Int {
                    httpBody.appendString(UploadURLRequestHelper().convertFormField(named: key, value: "\(temp)", using: boundary))
                }
                else if let temp = value as? [String] {
                    let arrData =  try? JSONSerialization.data(withJSONObject: temp, options: .prettyPrinted)
                    if let data = arrData {
                        httpBody.append(UploadURLRequestHelper().convertFileFieldData(named: key, value: data, using: boundary))
                    }
                }
            }
        }

        if let fileData = data.data {
            httpBody.append(UploadURLRequestHelper().convertFileData(fieldName: data.dataKey,
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

class MultipleUploadURLRequest<T: Mappable, K: Mappable> : UploadRequestProtocol {
    
    typealias RequestDataType = MultipleUploadRequestModel
    
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
                    httpBody.appendString( UploadURLRequestHelper().convertFormField(named: key, value: temp, using: boundary))
                }
                else if let temp = value as? Int {
                    httpBody.appendString(UploadURLRequestHelper().convertFormField(named: key, value: "\(temp)", using: boundary))
                }
                else if let temp = value as? [String] {
                    let arrData =  try? JSONSerialization.data(withJSONObject: temp, options: .prettyPrinted)
                    if let data = arrData {
                        httpBody.append(UploadURLRequestHelper().convertFileFieldData(named: key, value: data, using: boundary))
                    }
                }
            }
        }

        if data.localPaths.count > 0 {
            let data = try UploadURLRequestHelper().convertMultipleFileData(fieldName: data.dataKey, fileUrlPaths: data.localPaths, using: boundary)
            httpBody.append(data)
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

class UploadURLRequestLoader<T: UploadRequestProtocol>: NSObject {
    
    let apiRequest: T
    let manager: APIRequestState
    
    private let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
    private lazy var urlSession:URLSession = URLSession(configuration: config)
    
    init(apiRequest: T, session: APIRequestState = .live) {
        self.apiRequest = apiRequest
        self.manager = session
    }
    
    func uploadAPIRequest(requestData: T.RequestDataType, success: @escaping (T.SuccessResponseType) -> Void, error: @escaping (T.ErrorResponseType) -> Void, failure: @escaping (String) -> Void) {
        
        if !Reachability.isConnectedToNetwork() {
            failure("The internet connection appears to be offline.")
            return
        }
        
        do  {
            let urlReqest = try self.apiRequest.makeRequest(from: requestData, requestState: manager)
            let session = URLSession(configuration: .default)
            let uploadTask = session.dataTask(with: urlReqest) { data, response, err in
                
                if let error = err {
                    failure(error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    failure(NetworkError.noRecords)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    failure("Unable to fetch response")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let statusCode = response.statusCode
                    if (200..<300).contains(statusCode) {
                        do {
                            let parsedData = try self.apiRequest.parseSuccessResponse(data: json)
                            success(parsedData)
                        } catch let error {
                            let error = self.apiRequest.parseFailureResponse(status: 0, data: error)
                            failure(error)
                        }
                    } //: 200..<300
                    
                    else if (400..<500).contains(statusCode) {
                        do {
                            let parsedData = try self.apiRequest.parseErrorResponse(data: json)
                            error(parsedData)
                        } catch let error {
                            let error = self.apiRequest.parseFailureResponse(status: 0, data: error)
                            failure(error)
                        }
                    } //: 400..<500
                    
                    else {
                        let parsedData = self.apiRequest.parseFailureResponse(status: statusCode, data: json)
                        failure(parsedData)
                    } //
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    failure(errorData.localizedDescription)
                }
            } // : Task
            
            uploadTask.resume()
            
        } catch _ {
            
        }
    }
    
}

