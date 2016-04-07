//
//  Player.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/16/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class Player {
    
    private var _name: String!
    private var _weight: String!
    private var _year: String!
    private var _record: String!
    private var _imageURL: String!
    private var _postKey: String!
    
    var name: String {
        return _name
    }
    
    var weight: String {
        return _weight
    }
    
    var year: String {
        return _year
    }
    
    var record: String {
        return _record
    }
    
    var imageURL: String {
        return _imageURL
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(name: String, weight: String, year: String, record: String, imageURL: String) {
        
        self._name = name
        self._weight = weight
        self._year = year
        self._record = record
        self._imageURL = imageURL
        
    }
    
    init(){}
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let name = dictionary["name"] as? String {
            self._name = name
        }
        
        if let weight = dictionary["weight"] as? String {
            self._weight = weight
        }
        
        if let year = dictionary["year"] as? String {
            self._year = year
        }
        
        if let record = dictionary["record"] as? String {
            self._record = record
        }
        
        if let imageURL = dictionary["imageurl"] as? String {
            self._imageURL = imageURL
        }
        
    }
    
}
