//
//  Coach.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/14/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import Foundation
import Firebase

class Coach {
    
    private var _name: String!
    private var _imageURL: String!
    private var _title: String!
    private var _postKey: String!
    private var _descrip: String!
    
    var title: String {
        return _title
    }
    
    var name: String {
        return _name
    }
    
    var profileImg: String {
        return _imageURL
    }
    
    var postKey: String {
        return _postKey
    }
    
    var descrip: String {
        return _descrip
    }
    
    init(name: String, imageURL: String, title: String) {
        self._name = name
        self._imageURL = imageURL
        self._title = title
    }
    
    init(){}
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let title = dictionary["title"] as? String {
            self._title = title
        }
        
        if let imageURL = dictionary["imageurl"] as? String {
            self._imageURL = imageURL
        }
        
        if let name = dictionary["name"] as? String {
            self._name = name
        }
        
        if let coachDescription = dictionary["description"] as? String {
            self._descrip = coachDescription
        }
        
    }
    
}
