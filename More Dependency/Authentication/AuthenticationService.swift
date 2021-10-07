//
//  AuthenticationService.swift
//  More Dependency
//
//  Created by Rajendra karki on 10/5/21.
//

import Foundation

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
        let loader = DataRequestLoader(apiRequest: request)
        
        loader.loadAPIRequest(requestData: model) { (response) in
            success(response)
        } error: { (response) in
            error(response)
        }  failure: { (errorMessage) in
            failure(errorMessage)
        }
    }
    
    func loginDownload(request:Login.Request, success: @escaping (Login.Response) -> (), error: @escaping (Login.Response) -> (), failure: @escaping (String) -> ()) {
        
        let urlString: String = Urls.Auth.login.make()
        
        let model = DownloadRequestModel(
            url: urlString,
            method: "GET",
            destination: nil,
            requiresAuthorization: true
        )
        
        let request = DownloadURLRequest<Login.Response>()
        let loader = DownloadURLRequestLoader(apiRequest: request)
        loader.progressHandler = { progress in
            
        }
        loader.downloadAPIRequest(requestData: model) { (filePathURl, responseUrl) in
            print(filePathURl.absoluteString)
            print(responseUrl.absoluteString)
        } failure: { (errorMessage) in
            failure(errorMessage)
        }
    }
  
}


