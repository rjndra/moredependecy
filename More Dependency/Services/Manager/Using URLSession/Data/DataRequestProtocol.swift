//
//  DataRequestProtocol.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation

protocol DataRequestProtocol {
    associatedtype RequestDataType
    associatedtype SuccessResponseType
    associatedtype ErrorResponseType
    associatedtype FailureResponseType
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest
    func parseSuccessResponse(data: Any) throws -> SuccessResponseType
    func parseErrorResponse(data: Any) throws -> ErrorResponseType
    func parseFailureResponse(status: Int, data: Any) -> FailureResponseType
}
