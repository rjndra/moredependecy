//
//  DownloadAPIRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation

class AlamofireDownloadRequestLoader<T: AlamofireDownloadRequestProtocol> {
    
    let apiRequest: T
    let manager: APIRequestState
    
    init(apiRequest: T, session: APIRequestState = .live) {
        self.apiRequest = apiRequest
        self.manager = session
    }
    
    func downloadAPIRequest(requestData: T.RequestDataType, progressHandler: @escaping ((Double) -> ()), success: @escaping ((URL)) -> Void, failure: @escaping (String) -> Void) {
        
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
                
                guard let fileURL = response.fileURL else {
                    let error = self.apiRequest.parseErrorResponse(status: 0, data: response.result)
                    failure(error)
                    return
                }
                let fileURLPath = URL(fileURLWithPath: fileURL.path)
                let successData = (fileURLPath)
                success(successData)
            })
            
            
        } catch let error {
            let error = self.apiRequest.parseErrorResponse(status: 0, data: error)
            failure(error)
        }
    }
    
}

