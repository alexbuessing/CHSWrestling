//
//  Event.swift
//  Wrestling
//
//  Created by Alexander Buessing on 4/6/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class Event {
    
    private var _eventDescription: String!
    private var _time: String!
    private var _location: String!
    private var _date: String!
    
    var eventDescription: String {
        return _eventDescription
    }
    
    var time: String {
        return _time
    }
    
    var location: String {
        return _location
    }
    
    var date: String {
        return _date
    }
    
    init(eventDescription: String, time: String, location: String, date: String) {
        
        self._eventDescription = eventDescription
        self._time = time
        self._location = location
        self._date = date
        
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let eventDescription = dictionary["description"] as? String {
            self._eventDescription = eventDescription
        }
        
        if let time = dictionary["time"] as? String {
            self._time = time
        }
        
        if let location = dictionary["location"] as? String {
            self._location = location
        }
        
        if let date = dictionary["date"] as? String {
            self._date = date
        }
        
    }
    
}
