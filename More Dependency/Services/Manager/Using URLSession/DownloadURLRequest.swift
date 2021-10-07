//
//  DownloadURLRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/6/21.
//

import Foundation
import ObjectMapper

struct DownloadRequestModel {
    var url: String
    var method: String = "GET"
    var parameters: [String:Any]? = nil
    var encoding:JSONSerialization.WritingOptions = []
    var headers: [String:String]? = nil
    var destination: String? = nil
    var requiresAuthorization: Bool = true
}

protocol DownloadRequestProtocol {
    associatedtype RequestDataType
    var destination:String? { get set }
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest
    func destinationURL() -> URL?
    func parseErrorResponse(status: Int, data: Any) -> String
}

class DownloadURLRequest<T: Mappable> : DownloadRequestProtocol {
    
    internal var destination: String?
    
    typealias RequestDataType = DownloadRequestModel
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest {
        
        self.destination = data.destination
        var urlRequest = URLRequest(url: URL(string: data.url)!)
        urlRequest.httpMethod = data.method
        
        if let params = data.parameters {
            let body = try JSONSerialization.data(withJSONObject: params, options: data.encoding)
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
    
    func destinationURL() -> URL? {
        guard let path = self.destination else {
            return nil
        }
        let destinationURL = URL(fileURLWithPath: path, isDirectory: false)
        return destinationURL
    }
    
    func parseErrorResponse(status: Int, data: Any) -> String {
        let response  = NetworkUtilities().parseResponseError(status: status, data: data)
        return response
    }
}

class DownloadURLRequestLoader<T: DownloadRequestProtocol>: NSObject, URLSessionDownloadDelegate {

    let apiRequest: T
    let manager: APIRequestState
    
    var progress: ((Double) -> ())
    var success: ((URL) -> ())?
    var failure: ((String) -> ())?
    
    private let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
    private lazy var urlSession:URLSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    
    private var downloadTask: URLSessionDownloadTask!
    
    init(apiRequest: T, progressHandler: @escaping ((Double) -> ()), session: APIRequestState = .live) {
        self.apiRequest = apiRequest
        self.manager = session
        self.progress = progressHandler
    }
    
    func downloadAPIRequest(requestData: T.RequestDataType) {
        
        if !Reachability.isConnectedToNetwork() {
            failure?("The internet connection appears to be offline.")
            return
        }
        
        do {
            let urlReqest = try self.apiRequest.makeRequest(from: requestData, requestState: manager)
            let downloadTask = urlSession.downloadTask(with: urlReqest)
            self.downloadTask = downloadTask
            downloadTask.resume()
        } catch let error {
            let error = self.apiRequest.parseErrorResponse(status: 0, data: error)
            failure?(error)
        }
        
    }
    
    // For progress handler
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
           let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                self.progress(downloadTask.progress.fractionCompleted)
            }
        } else {
            // Fallback on earlier versions
            DispatchQueue.main.async {
                self.progress(Double(calculatedProgress))
            }
        }
    }
    
    // For task completion
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if task == self.downloadTask {
            if let error = error  {
                failure?(error.localizedDescription)
            } else if let destination = self.apiRequest.destinationURL() {
                success?(destination)
            } else {
                
            }
        }
    }
    
    // For download finish
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if downloadTask == self.downloadTask {
            let message = "Download finished: \(location.absoluteString)"
            print(message)
            
            guard let destinationURL = self.apiRequest.destinationURL() else {
                return
            }
            
            let fileManager = FileManager()
            
            // Remove previous file if present
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            
            // Created intermediate Directories
            let directory = destinationURL.deletingLastPathComponent()
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            
            // Move file to given destination Path
            try? fileManager.moveItem(at: location, to: destinationURL)
        }
    }
    
}


