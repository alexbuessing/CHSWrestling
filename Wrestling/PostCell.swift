//
//  PostCell.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/11/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

protocol Alert {
    func showAlert(post: Post)
}

class PostCell: UITableViewCell {

    @IBOutlet var mainImg: UIImageView!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var likesLbl: UILabel!
    @IBOutlet var likeImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var profileImg: UIImageView!
    @IBOutlet var editPostImg: UIImageView!
    
    var delegate: Alert?
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    var postRef: Firebase!
    var defaults = NSUserDefaults.standardUserDefaults()
    var profileImage: UIImage!
    var myPost: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
        let delete = UITapGestureRecognizer(target: self, action: #selector(PostCell.deleteTapped(_:)))
        delete.numberOfTapsRequired = 1
        editPostImg.addGestureRecognizer(delete)
        editPostImg.userInteractionEnabled = true
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        profileImg.clipsToBounds = true
        
        mainImg.layer.cornerRadius = 3.0
        mainImg.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) {

        self.post = post
        userName.text = post.username
        
        let user = String(defaults.valueForKey(KEY_UID)!)

        if user == String(post.userID) || checkIfManager(user) {
            editPostImg.hidden = false
        } else {
            editPostImg.hidden = true
        }
        
        if let data = defaults.valueForKey("profileImage") {
            profileImg.image = UIImage(data: data as! NSData)
        } else {
            profileImg.image = UIImage(named: "EmptyProfile")
        }
        
        postRef = DataService.ds.REF_POSTS.childByAppendingPath(post.postKey)
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageURL != nil {
            
            if img != nil {
                self.mainImg.image = img
                self.mainImg.hidden = false
            } else {
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, error in
                    
                    if error == nil {
                        let img = UIImage(data: data!)!
                        self.mainImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                        self.mainImg.hidden = false
                    } else {
                        print(error.debugDescription)
                    }
                })
            }
            
        } else {
           mainImg.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
            if let _ = snapshot.value as? NSNull {
                //This means that we have not liked this specific post
                self.likeImage.image = UIImage(named: "HeartIconEmpty")
            } else {
                self.likeImage.image = UIImage(named: "HeartIconFilled")
            }
        })
    }
    
    func deleteTapped(sender: UITapGestureRecognizer) {

        self.delegate?.showAlert(myPost)
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        //print(postRef)
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let _ = snapshot.value as? NSNull {
                //This means that we have not liked this specific post
                self.likeImage.image = UIImage(named: "HeartIconFilled")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "HeartIconEmpty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
    
    func checkIfManager(user: String) -> Bool {
        
        let managerArray = defaults.valueForKey("managersArray") as! [String]
        
        for value in managerArray {
            if value == user {
                return true
            }
        }
        
        return false
    }
    
}



