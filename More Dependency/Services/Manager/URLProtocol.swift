//
//  URLProtocol.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation

public enum ProjectServer:String, CaseIterable {
    case test
    case qa
}

enum ProjectBundle:String {
    case debug = "com.rajendra.More-Dependency.debug"
    case release = "com.rajendra.More-Dependency"
}

struct ProjectServerURL {
    static let qa = "http://qa-api.fakeProject.com/"
    static let live = "https://api.fakeProject.com/"
    
}

struct Urls {
    
#if DEBUG
    var baseUrl: String = ProjectServerURL.qa
#else
    var baseUrl: String = (ProjectBundle.release.rawValue == bundleIdentifierr) ? ProjectServerURL.live : ProjectServerURL.qa
#endif
}

protocol UrlsProtocl {
    func noBase() -> String
    
    func make() -> String
    
    func makePath(method:String) -> String
    
    func make(with slug:String) -> String
}

extension UrlsProtocl where Self: RawRepresentable, Self.RawValue == String {
    
    func noBase() -> String {
        return "api/v1/" + self.rawValue
    }
    
    func make() -> String {
        return Urls().baseUrl + self.noBase()
    }
    
    func makePath(method:String) -> String {
        return self.rawValue + "/" + method
    }
    
    func make(with slug:String) -> String {
        return Urls().baseUrl + "api/v1/" + self.rawValue + slug
    }
}

