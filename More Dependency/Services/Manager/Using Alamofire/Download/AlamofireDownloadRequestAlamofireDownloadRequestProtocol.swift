//
//  AlamofireDownloadRequest.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Alamofire

protocol AlamofireDownloadRequestProtocol {
    associatedtype RequestDataType
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> DownloadRequest
    func parseErrorResponse(status: Int, data: Any) -> String
}
