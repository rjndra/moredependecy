//
//  JSONExtension.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import SwiftyJSON
import ObjectMapper

extension JSON {
    func map<T: Mappable>() -> [T]? {
        let json = self.array
        let mapped: [T]? = json?.compactMap ({$0.map()})
        return mapped
    }
    
    func map<T: Mappable>() -> T? {
        let obj: T? = Mapper<T>().map(JSONObject: self.object)
        return obj
    }
    
    func map<T: Mappable>() -> Dictionary<String,T>? {
        let obj = Mapper<T>().mapDictionary(JSONObject: self.object)
        return obj
    }
    
    public var date: Date? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str)
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()
}
