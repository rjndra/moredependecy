//
//  NormalDataRequestLoader.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation

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
                    failure(errorData.localizedDescription as! T.FailureResponseType)
                }
            } // : Task
            
            task.resume()
        } catch let errorData {
            failure(errorData.localizedDescription as! T.FailureResponseType)
        }
        
    }
    
    
}

