//
//  APIManager.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Alamofire

class APIManager {
    
    static let shared = APIManager()
    
    var state: APIRequestState = APIRequestState.live
    
    var uploadRequest:UploadRequest?

}

extension APIManager {
    open func saveCookies(response: DataResponse<Any, Error>) {
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.response?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        var cookieArray = [[HTTPCookiePropertyKey: Any]]()
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
        UserDefaults.standard.synchronize()
    }
}

public func allHeaders(with headers:HTTPHeaders?, session: Session) -> HTTPHeaders {
    AF.sessionConfiguration.headers  = .default
    var newHeaders:HTTPHeaders = session.sessionConfiguration.headers
    

     // Needed only if single acces token is used for every login.
    let version = appVersion == nil ? "" : "\(appVersion ?? "0.0.0")"
    let bundle = bunldeNumber == nil ? "" : "(\(bunldeNumber ?? "0"))"
    let deviceId = deviceID == nil ? "" : "\(deviceID ?? "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")"
    
     newHeaders.update(HTTPHeader(name: "App-Version", value: version+bundle))
     newHeaders.update(HTTPHeader(name: "OS-Version", value: osVersion))
     newHeaders.update(HTTPHeader(name: "Device", value: "iOS"))
     newHeaders.update(HTTPHeader(name: "Device-Name", value: deviceName))
     newHeaders.update(HTTPHeader(name: "Device-Model", value: deviceModel))
     newHeaders.update(HTTPHeader(name: "Device-Id", value: deviceId))
    
    newHeaders.update(HTTPHeader(name: "Accept", value: "application/json"))
    for val in headers?.shuffled() ?? [HTTPHeader]() {
        newHeaders.update(val)
    }
    return newHeaders
}



