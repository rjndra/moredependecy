//
//  DataRequestModel.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import Alamofire

struct DataRequestModel {
    var url: URLConvertible
    var method: HTTPMethod = .get
    var parameters: Parameters? = nil
    var encoding: ParameterEncoding = URLEncoding.default
    var headers: HTTPHeaders? = nil
    var requiresAuthorization: Bool = true
}
