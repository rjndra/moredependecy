//
//  DownloadRequestProtocol.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import Foundation

protocol DownloadRequestProtocol {
    associatedtype RequestDataType
    var destination:String? { get set }
    
    func makeRequest(from data: RequestDataType, requestState: APIRequestState) throws -> URLRequest
    func destinationURL() -> URL?
    func parseErrorResponse(status: Int, data: Any) -> String
}
