//
//  AuthenticationService.swift
//  More Dependency
//
//  Created by Rajendra karki on 10/5/21.
//

import Foundation
import Alamofire

extension Urls {
    
    enum Auth:String, UrlsProtocl {
        
        /// /api.member/v1/auth/login
        ///    - POST
        ///    - "email":"testrepcts@gmail.com",
        ///    - "password": "Cts@2019",
        ///    - "device_id":"FXJhTWGkZxiLJSilEY:APA91bHtvldnpUFg7oUQxVNgQVDZJqqsDBSOm17UJnoeLpzb-KLSPDbefBl6pEcdha0zAAI04uGMtkv1QLnCM305rhogOEjpU8M7AxwMM0_F1rf7Fu6-GnBlumAbeaqZHmKBvl-tjawZ",
        ///    - "user_tpye":"A"
        case login = "auth/login"
        
           
    }
}

protocol AuthenticationService {
    func login(request:Login.Request, success: @escaping (Login.Response) -> (), error: @escaping (Login.Response) -> (), failure: @escaping (String) -> ())
    func downloadFile(url:String, destinationPath:String, progressHandler: @escaping ((Double) -> ()), success: @escaping (_ filePathURL: URL) -> (), failure: @escaping (String) -> ())
    func downloadFileAlamofire(url:String, destinationPath:String, progressHandler: @escaping ((Double) -> ()), success: @escaping (_ filePathURL: URL) -> (), failure: @escaping (String) -> ())
}

class AuthenticationServiceImpl: AuthenticationService {
    
    
    func login(request:Login.Request, success: @escaping (Login.Response) -> (), error: @escaping (Login.Response) -> (), failure: @escaping (String) -> ()) {
        
        let urlString: String = Urls.Auth.login.make()
        
        let model = AlamofireDataRequestModel(
            url: urlString,
            method: .post,
            parameters: request.body(),
            requiresAuthorization: false
        )
        
        let request = AlamofireDataRequest<Login.Response,Login.Response>()
        let loader = AlamofireDataRequestLoader(apiRequest: request)
        
        loader.loadAPIRequest(requestData: model) { (response) in
            success(response)
        } error: { (response) in
            error(response)
        }  failure: { (errorMessage) in
            failure(errorMessage)
        }
    }
    
    func downloadFile(url:String, destinationPath:String, progressHandler: @escaping ((Double) -> ()), success: @escaping (_ filePathURL: URL) -> (), failure: @escaping (String) -> ()) {
        
        let urlString: String = url
        
        let model = DownloadRequestModel(
            url: urlString,
            method: "GET",
            destination: destinationPath,
            requiresAuthorization: true
        )
        
        let request = DownloadURLRequest<Login.Response>()
        let loader = DownloadRequestLoader(apiRequest: request, progressHandler: progressHandler)
        loader.success = { (filePathUrl) in
            print(filePathUrl.absoluteString)
            success(filePathUrl)
        }
        loader.failure = { (errorMessage) in
            failure(errorMessage)
        }
        loader.downloadAPIRequest(requestData: model)
    }
    
    
    
    func downloadFileAlamofire(url:String, destinationPath:String, progressHandler: @escaping ((Double) -> ()), success: @escaping (_ filePathURL: URL) -> (), failure: @escaping (String) -> ()) {
        
        let urlString: String = url
        
        let toURL = URL(fileURLWithPath: destinationPath, isDirectory: false)
        
        let destination: DownloadRequest.Destination = { _,_ in
            return (toURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let model = AlamofireDownloadRequestModel(
            url: urlString,
            method: .post,
            destination: destination,
            requiresAuthorization: true
        )
        
        let request = AlamofireDownloadRequest()
        let loader = AlamofireDownloadRequestLoader(apiRequest: request)
        loader.downloadAPIRequest(requestData: model, progressHandler: progressHandler)
        { (filePathUrl) in
            print(filePathUrl.absoluteString)
            success(filePathUrl)
        } failure: { (errorMessage) in
            failure(errorMessage)
        }
    }
  
}


