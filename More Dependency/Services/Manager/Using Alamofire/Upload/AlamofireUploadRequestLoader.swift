//
//  AlamofireUploadRequestLoader.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import Alamofire
import SwiftyJSON

class AlamofireUploadRequestLoader<T: AlamofireUploadRequestProtocol> {
    
    let apiRequest: T
    let manager: APIRequestState
    
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
            let request = try self.apiRequest.makeRequest(from: requestData, requestState: manager)
            
            func handle(result: Result<Any,AFError>, code: Int?) {
                switch result {
                case .success(let data):
                    guard let statusCode = code  else {
                        let error = self.apiRequest.parseFailureResponse(status: 0, data: data)
                        failure(error)
                        return
                    }
                    
                    if (200..<300).contains(statusCode) {
                        do {
                            let parsedData = try self.apiRequest.parseSuccessResponse(data: data)
                            success(parsedData)
                        } catch let error {
                            let error = self.apiRequest.parseFailureResponse(status: 0, data: error)
                            failure(error)
                        }
                    }
                    else if (400..<500).contains(statusCode) {
                        do {
                            let parsedData = try self.apiRequest.parseErrorResponse(data: data)
                            error(parsedData)
                        } catch let error {
                            let error = self.apiRequest.parseFailureResponse(status: 0, data: error)
                            failure(error)
                        }
                    }
                    else {
                        let parsedData = self.apiRequest.parseFailureResponse(status: statusCode, data: data)
                        failure(parsedData)
                    }
                case .failure(let error):
                    let error = self.apiRequest.parseFailureResponse(status: 0, data: error)
                    failure(error)
                }
            }
            
            request.responseJSON { (response) in
                handle(result: response.result, code: response.response?.statusCode)
            }
            
        } catch _ {
            
        }
    }
    
}

