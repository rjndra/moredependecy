//
//  APIRequestManager.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import Alamofire

enum APIRequestState {
    case live
    case mock
    
    var session: Session {
        switch self {
        case .live: return APIRequestManager.shared.liveManager
        case .mock: return APIRequestManager.shared.mockManager
        }
    }
}

class APIRequestManager {
    
    static let shared = APIRequestManager()
    fileprivate let liveManager: Session
    fileprivate let mockManager: Session
    
    init(_ state: APIRequestState = .live) {
        
        let mockSessionManager: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockingURLProtocol.self]
            return configuration
        }()
        
        let liveSessionManager: Session = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 30
            return  Session(configuration: configuration)
        }()
        
        self.liveManager = liveSessionManager
        self.mockManager = Session(configuration: mockSessionManager)
    }
}
