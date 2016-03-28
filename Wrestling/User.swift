//
//  User.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/26/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class User {
    
    private var _username: String!
    
    var username: String {
        return _username
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let name = dictionary["username"] as? String {
            self._username = name
        }
        
    }
    
}
