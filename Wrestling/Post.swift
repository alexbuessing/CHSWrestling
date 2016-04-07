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
    private var _likeRef: Firebase!
    private var _deletePostRef: Firebase!
    private var _userID: AnyObject!
    
    var userID: AnyObject {
        return _userID
    }
    
    var likeRef: Firebase {
        get {
            return _likeRef
        } set (newValue) {
            _likeRef = newValue
        }
    }
    
    var deletePostRef: Firebase {
        get {
            return _deletePostRef
        } set (newValue) {
            _deletePostRef = newValue
        }
    }
    
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
        
        if let user = dictionary["username"] as? String {
            self._username = user
        }
        
        if let ID = dictionary["userID"] {
            self._userID = ID
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
