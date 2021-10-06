//
//  NormalDataDownloadRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/6/21.
//

import Foundation
import ObjectMapper

struct DownloadURLRequestModel {
    var url: String
    var method: String = "GET"
    var destination: String? = nil
    var requiresAuthorization: Bool = true
}

protocol DownloadURLAPIRequest {
    associatedtype RequestDataType
    var destination:String? { get set }
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest
    func fileDestination() -> String?
    func parseErrorResponse(status: Int, data: Any) -> String
}

class DataDownloadAPIRequest<T: Mappable> : DownloadURLAPIRequest {
    
    internal var destination: String?
    
    typealias RequestDataType = DownloadURLRequestModel
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest {
        
        self.destination = data.destination
        var urlRequest = URLRequest(url: URL(string: data.url)!)
        urlRequest.httpMethod = data.method
        
        if urlRequest.headers["Content-Type"] == nil {
            urlRequest.headers.update(.contentType("application/json"))
        }

        return urlRequest
    }
    
    func fileDestination() -> String? {
        return self.destination
    }
    
    func parseErrorResponse(status: Int, data: Any) -> String {
        let response  = NetworkUtilities().parseResponseError(status: status, data: data)
        return response
    }
}

class DownloadURLRequestLoader<T: DownloadURLAPIRequest>: NSObject, URLSessionDownloadDelegate {

    let apiRequest: T
    let manager: APIRequestState
    
    var progressHandler: ((Double) -> ())?
    
    init(apiRequest: T, session: APIRequestState = .live) {
        self.apiRequest = apiRequest
        self.manager = session
    }
    
    func downloadAPIRequest(requestData: T.RequestDataType, success: @escaping ((URL, URL)) -> Void, failure: @escaping (String) -> Void) {
        
        if !Reachability.isConnectedToNetwork() {
            failure("The internet connection appears to be offline.")
            return
        }
        
        do {
            let urlReqest = try self.apiRequest.makeRequest(from: requestData, requestState: manager)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
            let task = session.downloadTask(with: urlReqest) { (tempFileUrl, response, error) in
                
                if let error = error {
                    failure(error.localizedDescription)
                    return
                }
                
                if let dataTempUrl = tempFileUrl, let reponseUrl = response?.url {
                    success((dataTempUrl, reponseUrl))
                } else {
                    failure("Unable to download")
                }
            }
            
            task.resume()
        } catch let error {
            let error = self.apiRequest.parseErrorResponse(status: 0, data: error)
            failure(error)
        }
        
    }
    
    // For progress handler
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progressValue = Double(totalBytesWritten/totalBytesExpectedToWrite)
        progressHandler?(progressValue)
    }
    
    // For destination url
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let path = self.apiRequest.fileDestination() else {
            return
        }
        let toURL = URL(fileURLWithPath: path, isDirectory: false)
        try? FileManager().moveItem(at: location, to: toURL)
    }
    
    
}


