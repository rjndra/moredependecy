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

protocol DataRequestProtocol {
    associatedtype RequestDataType
    associatedtype SuccessResponseType
    associatedtype ErrorResponseType
    associatedtype FailureResponseType
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest
    func parseSuccessResponse(data: Any) throws -> SuccessResponseType
    func parseErrorResponse(data: Any) throws -> ErrorResponseType
    func parseFailureResponse(status: Int, data: Any) -> FailureResponseType
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


class NormalDataRequestLoader<T: DataRequestProtocol>: NSObject {
    
    let apiRequest: T
    let manager: APIRequestState
    
    var progressHandler: ((Double) -> ())?
    
    init(apiRequest: T, session: APIRequestState = .live) {
        self.apiRequest = apiRequest
        self.manager = session
    }
    
    func loadRequest(requestData: T.RequestDataType, success: @escaping (T.SuccessResponseType) -> Void, error: @escaping (T.ErrorResponseType) -> Void, failure: @escaping (T.FailureResponseType) -> Void) {
        
        if !Reachability.isConnectedToNetwork() {
            failure("The internet connection appears to be offline." as! T.FailureResponseType)
            return
        }
        
        do {
            let urlReqest = try self.apiRequest.makeRequest(from: requestData, requestState: manager)
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: urlReqest) { data, response, err in
                
                if let error = err {
                    failure(error.localizedDescription as! T.FailureResponseType)
                    return
                }
                
                guard let data = data else {
                    failure(NetworkError.noRecords as! T.FailureResponseType)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    failure("Unable to fetch response" as! T.FailureResponseType)
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
                    }
                    else if (400..<500).contains(statusCode) {
                        do {
                            let parsedData = try self.apiRequest.parseErrorResponse(data: json)
                            error(parsedData)
                        } catch let error {
                            let error = self.apiRequest.parseFailureResponse(status: 0, data: error)
                            failure(error)
                        }
                    }
                    else {
                        let parsedData = self.apiRequest.parseFailureResponse(status: statusCode, data: json)
                        failure(parsedData)
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    failure(errorData.localizedDescription as! T.FailureResponseType)
                }
            } // : Task
            
            task.resume()
        } catch let errorData {
            failure(errorData.localizedDescription as! T.FailureResponseType)
        }
        
    }
    
    
}



