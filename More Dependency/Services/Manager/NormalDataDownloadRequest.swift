//
//  NormalDataDownloadRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/6/21.
//

import Foundation
import ObjectMapper

struct DownloadURLRequestModel {
    
    public typealias DownloadDestination = (_ temporaryURL: URL,
                                            _ response: HTTPURLResponse) -> (destinationURL: URL, options: JSONSerialization.ReadingOptions)
    var url: String
    var method: String = "GET"
    var destination: DownloadDestination? = nil
    var requiresAuthorization: Bool = true
}


protocol DownloadURLAPIRequest {
    associatedtype RequestDataType
    
    func makeDownloadURLRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest
    func parseErrorResponse(status: Int, data: Any) -> String
}

class DownloadURLRequestLoader<T: DownloadURLAPIRequest>: NSObject, URLSessionDownloadDelegate {

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
            let urlReqest = try self.apiRequest.makeDownloadURLRequest(from: requestData, requestState: manager)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
            let task = session.downloadTask(with: urlReqest) { (tempFileUrl, urlResponse, error) in
                
            }
            
            task.resume()
        } catch let error {
            let error = self.apiRequest.parseErrorResponse(status: 0, data: error)
            failure(error)
        }
        
        
//        do {
//            let request = try self.apiRequest.makeRequest(from: requestData, requestState: manager)
//
//            request.downloadProgress(closure: { (progress) in
//                progressHandler(progress.fractionCompleted)
//            }).response(completionHandler: { (response) in
//                guard let statusCode = response.response?.statusCode, statusCode == 200  else {
//                    let error = self.apiRequest.parseErrorResponse(status: 0, data: response.result)
//                    failure(error)
//                    return
//                }
//
//                if statusCode == 401 { // Unauthorized
//                    let error = self.apiRequest.parseErrorResponse(status: 0, data: response.result)
//                        failure(error)
//                }
//
//                guard let fileURL = response.fileURL, let requestURL = response.request?.url else {
//                    let error = self.apiRequest.parseErrorResponse(status: 0, data: response.result)
//                    failure(error)
//                    return
//                }
//                let fileURLPath = URL(fileURLWithPath: fileURL.path)
//                let successData = (requestURL, fileURLPath)
//                success(successData)
//            })
//
//
//        } catch let error {
//            let error = self.apiRequest.parseErrorResponse(status: 0, data: error)
//            failure(error)
//        }
    }
    
    // For progress handler
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
    }
    
    // For destication url
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    
    
}



class DataDownloadAPIRequest<T: Mappable> : DownloadURLAPIRequest {
    
    typealias RequestDataType = DownloadURLRequestModel
    
    
    func makeDownloadURLRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest {
        
        var urlRequest = URLRequest(url: URL(string: data.url)!)
        urlRequest.httpMethod = data.method
        
        if urlRequest.headers["Content-Type"] == nil {
            urlRequest.headers.update(.contentType("application/json"))
        }

        return urlRequest
    }
    
    func parseErrorResponse(status: Int, data: Any) -> String {
        let response  = NetworkUtilities().parseResponseError(status: status, data: data)
        return response
    }
}
