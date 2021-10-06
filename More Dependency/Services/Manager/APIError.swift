//
//  APIError.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation

struct NetworkError {
    
    static let request_cancelled = "Request Cancelled"
    static let request_success = "Request success"
    
    static let technical = "Sorry there are some technical issue. Please try again later."
    static let tryAgain = "Oops! Something went wrong. Please try again later."
    static let timeOut = "The request timed out."
    static let incomplete = "Unable to complete process. Please try again."
    static let noConnection = "The internet connection appears to be offline."
    static let pageNotFound = "Page not found."
    static let noRecords = "No records found."
    static let noMoreRecords = "No more records found."
    static let poorConnection = "Seems you internet connectivity is very poor or fluctuating. Please connect stable network and try again."
    static let badRequest = "Bad Request. \n Request contains undesired data."
    static let unauthorized = "You are unauthorized to this request."
    static let forbidden = "You are fobidden to this request."
    static let notAllowed = "You are not allowed to perfrom this request."
    static let database = "Whoops, looks like there was database error."
    static let server = "Internal server error. Whoops, looks like something went wrong."
    static let temporaryUnavailable = "Service Temporary Unavailable"
    
    static let logoutIncomplete = "Unable to logout from account right now."
    static let logoutSuccess = "Successfully Logged Out"
    
    static let parseJSON = "Unable to parse JSON."
}

public enum APIError: Error {
    
    public enum NetworkFailureReason {
        case noConnection
        case poorConnection
        case unauthorized
        case forbidden
        case pageNotFound
        case notAllowed
        case database
        case server
        case timeOut
        case incomplete
    }
    
    
    public enum SerializationFailureReason {
        case parseJSON
        case missingJOSN(String)
        case mockJSON(String)
    }
    
    case SerializationFailed(reason: SerializationFailureReason)
    case NetworkFailed(reason: NetworkFailureReason)
}

extension Error {
    /// Returns the instance cast as an `AFError`.
    public var asAPIError: APIError? {
        self as? APIError
    }
}

extension APIError.SerializationFailureReason {
    var localizedDescription: String {
        switch self {
        case .parseJSON:
            return NetworkError.parseJSON
        case .missingJOSN(let name):
            return "Missing file: \(name).json"
        case .mockJSON(let name):
            return "Mock for \(name).json data not created"
        }
    }
}

extension APIError.NetworkFailureReason {
    var localizedDescription: String {
        switch self {
        case .noConnection:
            return NetworkError.noConnection
        case .poorConnection:
            return NetworkError.poorConnection
        case .unauthorized:
            return NetworkError.unauthorized
        case .forbidden:
            return NetworkError.forbidden
        case .pageNotFound:
            return NetworkError.pageNotFound
        case .notAllowed:
            return NetworkError.notAllowed
        case .database:
            return NetworkError.database
        case .server:
            return NetworkError.server
        case .timeOut:
            return NetworkError.timeOut
        case .incomplete:
            return NetworkError.incomplete
        }
    }
}
