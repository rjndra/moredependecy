//
//  DownloadRequestLoader.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation

class DownloadRequestLoader<T: DownloadRequestProtocol>: NSObject, URLSessionDownloadDelegate {

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


