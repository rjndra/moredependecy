//
//  NetworkUtilities.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import Alamofire
import ObjectMapper
import SwiftyJSON

typealias CompletionBlock          = () -> Void
typealias CallBackWithSuccessError = (_: Bool, _: Error?) -> Void
typealias SuccessEmptyBlock        = () -> Void
typealias FailureBlock             = (Error?) -> Void


class NetworkUtilities: NSObject {
    
    class func debounce(interval: Int, queue: DispatchQueue, action: @escaping (() -> Void)) {
        var lastFireTime = DispatchTime.now()
        let dispatchDelay = DispatchTimeInterval.milliseconds(interval)
        
        lastFireTime = DispatchTime.now()
        let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay
        
        queue.asyncAfter(deadline: dispatchTime) {
            let when: DispatchTime = lastFireTime + dispatchDelay
            let now = DispatchTime.now()
            if now.rawValue >= when.rawValue {
                action()
            }
        }
    }
}


extension NetworkUtilities {
    
    func readJson(forResource fileName: String, bundle: Bundle = Bundle.main) throws -> Data {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw APIError.SerializationFailed(reason: .missingJOSN(fileName))
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            throw APIError.SerializationFailed(reason: .mockJSON(fileName))
        }
    }
    
    func parseResponse<T: Mappable>(for data: Any) throws -> T {
        let json = JSON(data)
        if let value: T = json.map() {
            return value
        } else {
            let error = APIError.SerializationFailed(reason: .parseJSON)
            throw error
        }
    }
    
    func parseResponse<T: Mappable>(for data: Any) throws -> [T] {
        let json = JSON(data)
        if let value: [T] = json.map() {
            return value
        } else {
            let error = APIError.SerializationFailed(reason: .parseJSON)
            throw error
        }
    }
    
    func parseResponse(for data: Any) throws -> [String] {
        if let value:[String]  = data as? [String] {
            return value
        } else {
            let error = APIError.SerializationFailed(reason: .parseJSON)
            throw error
        }
    }
    
    func parseResponse<T: Mappable>(for data: Any) throws -> Dictionary<String,T> {
        let json = JSON(data)
        if let value:Dictionary<String,T> = json.map() {
            return value
        } else {
            let error = APIError.SerializationFailed(reason: .parseJSON)
            throw error
        }
    }
    
    func parseResponse(for data: Any) throws -> Dictionary<String,Any> {
        let json = JSON(data)
        if let value:Dictionary<String,Any> = json.dictionaryObject {
            return value
        } else {
            let error = APIError.SerializationFailed(reason: .parseJSON)
            throw error
        }
    }
    
    func parseResponse(for data: String) throws -> Dictionary<String,Any> {
        let json = JSON(parseJSON: data)
        if let value:Dictionary<String,Any> = json.dictionaryObject {
            return value
        } else {
            let error = APIError.SerializationFailed(reason: .parseJSON)
            throw error
        }
    }
    
    func parseResponseError(status: Int, data: Any) -> String {

        var error: String = APIError.NetworkFailed(reason: .incomplete).localizedDescription
        
        func setError() {
            switch status {
            case 401: // Unauthorized
                error = APIError.NetworkFailed(reason: .unauthorized).localizedDescription
            case 403: // Forbidden
                error = APIError.NetworkFailed(reason: .forbidden).localizedDescription
            case 404: // Not found
                error = APIError.NetworkFailed(reason: .pageNotFound).localizedDescription
            case 405: // Method Not Allowed
                error = APIError.NetworkFailed(reason: .notAllowed).localizedDescription
            case 422:
                error = APIError.NetworkFailed(reason: .database).localizedDescription
            case 500..<600: // Whoops, looks like something went wrong
                error = APIError.NetworkFailed(reason: .server).localizedDescription
            default:
                error = APIError.NetworkFailed(reason: .incomplete).localizedDescription
            }
        }
        
        do {
            let response:APIResponse =  try parseResponse(for: data)
            if status != 200 {
                setError()
            }
            if let message = response.message {
                return message
            } else {
                return error
            }
        }  catch let err {
            return err.localizedDescription
        }
    }
    
    func parseError(error: APIError) -> String {
        return error.localizedDescription
    }
    
}
