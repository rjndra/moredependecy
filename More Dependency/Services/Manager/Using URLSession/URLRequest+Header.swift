//
//  URLRequest+Header.swift
//  More Dependency
//
//  Created by Rajendra Karki on 07/10/2021.
//

import UIKit

extension URLRequest {
    
    mutating func updateHeader() {
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let bunldeNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
        if let version = appVersion,  let bundle = bunldeNumber {
            self.addValue(version+bundle, forHTTPHeaderField: "App-Version")
        }
        let deviceID = UIDevice.current.identifierForVendor?.uuidString
        if let deviceId = deviceID {
            self.addValue(deviceId, forHTTPHeaderField: "Device-Id")
        }
        self.addValue(osVersion, forHTTPHeaderField: "OS-Version")
        self.addValue("iOS", forHTTPHeaderField: "Device")
        self.addValue(deviceName, forHTTPHeaderField: "Device-Name")
        self.addValue(deviceModel, forHTTPHeaderField: "Device-Model")
        
        self.addValue("application/json", forHTTPHeaderField: "Accept")
    }
}
