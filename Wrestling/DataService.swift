//
//  DataService.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/11/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase

let URL_BASE = "https://concord-wrestling.firebaseio.com"

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_COACH = Firebase(url: "\(URL_BASE)/coach")
    private var _REF_PLAYER = Firebase(url: "\(URL_BASE)/player")
    private var _REF_DIVISION = Firebase(url: "\(URL_BASE)/division")
    private var _REF_STATE = Firebase(url: "\(URL_BASE)/state")
    private var _REF_NEWENGLAND = Firebase(url: "\(URL_BASE)/newengland")
    private var _REF_HOF = Firebase(url: "\(URL_BASE)/hof")
    
    var REF_DIVISION: Firebase {
        return _REF_DIVISION
    }
    
    var REF_STATE: Firebase {
        return _REF_STATE
    }
    
    var REF_NEWENGLAND: Firebase {
        return _REF_NEWENGLAND
    }
    
    var REF_HOF: Firebase {
        return _REF_HOF
    }
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_COACH: Firebase {
        return _REF_COACH
    }
    
    var REF_PLAYER: Firebase {
        return _REF_PLAYER
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        
        REF_USERS.childByAppendingPath(uid).setValue(user)
        
    }
    
}
