//
//  AuthenticatoinWorker.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import SwiftyJSON

extension UserDefaultKey {
    static let biometricSettingEnbled = UserDefaultKey(key: "biometry_setting_enabled".uppercased())
    static let user = UserDefaultKey(key: "user")
}

class AuthenticationWorker {
    
    private var webService: AuthenticationService
    
    init(service: AuthenticationService = AuthenticationServiceImpl()) {
        self.webService = service
    }
    
    func saveUserData(_ data: Login.Response) {
        AuthCache.AcessToken.save(token: data.access_token)
        AuthCache.AccessTokenType.save(token: data.token_type)
        let dictionary = data.toJSON()
        UserDefaultKey.user.set(value: dictionary)
    }
    
    func getUser() -> Login.Response? {
        if let value:[String:Any] = UserDefaultKey.user.value() {
            
            let json = JSON(value)
            guard let user:Login.Response = json.map() else {
                return nil
            }
            return user
        }
        return nil
    }
    
    func login(request:Login.Request, success: @escaping (Bool) -> (), failure: @escaping (String) -> ()) {
        
        self.webService.login(request: request) { (response) in
            self.saveUserData(response)
            success(true)
        } error: { (response) in
            self.saveUserData(response)
            success(false)
        } failure: { (errorMessage) in
            failure(errorMessage)
        }
        
    }
    
    func downloadAndSaveVideo(progress: @escaping ((Double) -> ()), success: @escaping (URL) -> (), failure: @escaping (String) -> ()) {
        let urlString = "https://corenroll.com/_pdfdocs/STD-500-HOSPITAL-INDEMNITY-POLICY.pdf"
        guard let fileURL = URL(string: urlString) else {
            return
        }
        let fileName = fileURL.lastPathComponent
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent("/Downloads/\(fileName)")

//        if FileManager().fileExists(atPath: destinationUrl.path) {
//            print("File already exists [\(destinationUrl.path)]")
//
//        } else {
            
            self.webService.downloadFile(url: urlString, destinationPath: destinationUrl.path, progressHandler: progress) { filePathURL in
                success(filePathURL)
            } failure: { (error) in
                failure(error)
            }
            
            self.webService.downloadFileAlamofire(url: urlString, destinationPath: destinationUrl.path, progressHandler: progress) { filePathURL in
                success(filePathURL)
            } failure: { error in
                failure(error)
            }

//        }

    }
   
    
}
