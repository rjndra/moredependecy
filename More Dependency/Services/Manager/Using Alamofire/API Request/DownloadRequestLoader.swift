//
//  DownloadAPIRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
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

protocol DownloadAPIRequest {
    associatedtype RequestDataType
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> DownloadRequest
    func parseErrorResponse(status: Int, data: Any) -> String
}

class DownloadRequestLoader<T: DownloadAPIRequest> {
    
    let apiRequest: T
    let manager: APIRequestState
    
    init(apiRequest: T, session: APIRequestState = .live) {
        self.apiRequest = apiRequest
        self.manager = session
    }
    
    func downloadAPIRequest(requestData: T.RequestDataType, progressHandler: @escaping ((Double) -> ()), success: @escaping ((URL, URL)) -> Void, failure: @escaping (String) -> Void) {
        
        if !Reachability.isConnectedToNetwork() {
            failure("The internet connection appears to be offline.")
            return
        }
        
        do {
            let request = try self.apiRequest.makeRequest(from: requestData, requestState: manager)
            
            request.downloadProgress(closure: { (progress) in
                progressHandler(progress.fractionCompleted)
            }).response(completionHandler: { (response) in
                guard let statusCode = response.response?.statusCode, statusCode == 200  else {
                    let error = self.apiRequest.parseErrorResponse(status: 0, data: response.result)
                    failure(error)
                    return
                }
                
                if statusCode == 401 { // Unauthorized
                    let error = self.apiRequest.parseErrorResponse(status: 0, data: response.result)
                        failure(error)
                }
                
                guard let fileURL = response.fileURL, let requestURL = response.request?.url else {
                    let error = self.apiRequest.parseErrorResponse(status: 0, data: response.result)
                    failure(error)
                    return
                }
                let fileURLPath = URL(fileURLWithPath: fileURL.path)
                let successData = (requestURL, fileURLPath)
                success(successData)
            })
            
            
        } catch let error {
            let error = self.apiRequest.parseErrorResponse(status: 0, data: error)
            failure(error)
        }
    }
    
}

