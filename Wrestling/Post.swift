//
//  Post.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/12/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _postDescription: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageURL: String? {
        return _imageURL
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageURL: String?, username: String) {
        
        self._postDescription = description
        self._imageURL = imageURL
        self._username = username
        
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgURL = dictionary["imageurl"] as? String {
            self._imageURL = imgURL
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
        
    }
    
    
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
        
    }
    
}
