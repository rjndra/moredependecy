//
//  AlamofireUploadRequestProtocol.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation
import Alamofire

protocol AlamofireUploadRequestProtocol {
    associatedtype RequestDataType
    associatedtype SuccessResponseType
    associatedtype ErrorResponseType
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> UploadRequest
    func parseSuccessResponse(data: Any) throws -> SuccessResponseType
    func parseErrorResponse(data: Any) throws -> ErrorResponseType
    func parseFailureResponse(status: Int, data: Any) -> String
}
