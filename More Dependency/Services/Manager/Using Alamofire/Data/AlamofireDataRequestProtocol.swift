//
//  AlamofireDataRequestProtocol.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Alamofire

protocol AlamofireDataRequestProtocol {
    associatedtype DataRequestType:DataRequest
    associatedtype RequestDataType
    associatedtype SuccessResponseType
    associatedtype ErrorResponseType
    associatedtype FailureResponseType
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> DataRequestType
    func parseSuccessResponse(data: Any) throws -> SuccessResponseType
    func parseErrorResponse(data: Any) throws -> ErrorResponseType
    func parseFailureResponse(status: Int, data: Any) -> FailureResponseType
}
