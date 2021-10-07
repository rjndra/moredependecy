//
//  UploadRequestLoader.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation

class UploadURLRequestLoader<T: UploadRequestProtocol> {
    
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

