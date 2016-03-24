//
//  Award.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/21/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class Award {
    
    private var _name: String!
    private var _text: String!
    
    var name: String {
        return _name
    }
    
    var text: String {
        return _text
    }
    
    init(name: String, text: String) {
        
        self._name = name
        self._text = text
        
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let name = dictionary["name"] as? String {
            self._name = name
        }
        
        if let text = dictionary["text"] as? String {
            self._text = text
        }
        
    }
    
}
