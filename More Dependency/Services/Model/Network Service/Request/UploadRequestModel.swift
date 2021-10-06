//
//  UploadRequestModel.swift
//  More Dependency
//
//  Created by Rajendra karki on 10/5/21.
//

import Foundation
import Alamofire

struct UploadRequestModel {
    var url: URLConvertible
    var method: HTTPMethod = .post
    var data: Data?
    var dataKey:String = "image"
    var parameters: Parameters? = nil
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: HTTPHeaders? = nil
    var requiresAuthorization: Bool = true
}

