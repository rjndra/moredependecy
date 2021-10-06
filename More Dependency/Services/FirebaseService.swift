//
//  FirebaseService.swift
//  More Dependency
//
//  Created by Rajendra Karki on 10/5/21.
//

import Foundation
import Firebase

struct FirebaseService {
    
    func getMessageToken() -> String? {
        guard let token =  Messaging.messaging().fcmToken else {
            return nil
        }
        return token
    }
    
}
