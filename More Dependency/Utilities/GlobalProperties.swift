//
//  GlobalProperties.swift
//  More Dependency
//
//  Created by CTN on 10/5/21.
//

import UIKit

var appDelegate = UIApplication.shared.delegate as! AppDelegate
let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
let bunldeNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String
let osVersion = UIDevice.current.systemVersion
let deviceModel = UIDevice.current.model
let systemName = UIDevice.current.systemName
let deviceName = UIDevice.current.name
let deviceID = UIDevice.current.identifierForVendor?.uuidString

