//
//  PreferencesVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/18/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class PreferencesVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var profileImage: MaterialImageView!
    @IBOutlet var clickLabel: UILabel!
    @IBOutlet var usernameTextField: MaterialTextField!
    @IBOutlet var cancelButton: UIButton!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var usernameArray = [String]()
    var data: NSData!
    let network = Func()
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if profileImage.image == UIImage(named: "EmptyProfile") {
            imageSelected = false
        } else {
            imageSelected = true
        }
        
        if !imageSelected {
            clickLabel.hidden = false
        } else {
            clickLabel.hidden = true
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !network.connectedToNetwork() {
            showErrorAlert("No Network Connection", msg: "Information may not be up to date. Please check your network connection.")
        }
        
        DataService.ds.REF_USERS.observeSingleEventOfType(.Value, withBlock: {snapshot in
            
            self.usernameArray = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots.reverse() {
                    //print("SNAP: \(snap)")
                    
                    if let postDic = snap.value as? Dictionary<String, AnyObject> {
                        
                        if let user = postDic["username"] as? String {
                            self.usernameArray.append(user)
                        }
                    }
                }
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        if let user = self.defaults.valueForKey("username") as? String {
            cancelButton.hidden = false
            usernameTextField.text = user
        } else {
            cancelButton.hidden = true
        }
        
        if let data = defaults.valueForKey("profileImage") {
            profileImage.image = UIImage(data: data as! NSData)
            clickLabel.hidden = true
        } else {
            profileImage.image = UIImage(named: "EmptyProfile")
        }
        
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func profileImagePressed(sender: AnyObject) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        data = UIImageJPEGRepresentation(image, 0.3)
        defaults.setObject(data, forKey: "profileImage")
        clickLabel.hidden = true
        imageSelected = true
        
    }
    
    @IBAction func saveUserInfo(sender: AnyObject) {
        
        if let img = profileImage.image where imageSelected == true {
            
            data = UIImageJPEGRepresentation(img, 0.3)
            defaults.setObject(data, forKey: "profileImage")
            
        }
        
        if network.connectedToNetwork() {
        if let txt = usernameTextField.text where txt != "" {
            
            if usernameTextField.text == defaults.valueForKey("username") as? String {
                //This is called if the username is still in the textfield
                self.performSegueWithIdentifier("segueToFeed", sender: nil)
            } else if isNewUsername(txt) {
                defaults.setObject(txt, forKey: "username")
                postToFirebase(nil)
                self.performSegueWithIdentifier("segueToFeed", sender: nil)
            } else {
                //Need to input notification
                showErrorAlert("Oops!", msg: "Username is already taken, please try a different username.")
                if let name = defaults.valueForKey("username") as? String {
                    usernameTextField.text = name
                } else {
                    usernameTextField.text = ""
                }
                print("Username taken")
            }
        }
        } else {
            showErrorAlert("No Network Connection", msg: "Username was not changed, please try again when you have a network connection.")
        }
    }
    
    func isNewUsername(newUser: String) -> Bool {
        
        for value in usernameArray {
            if newUser == value {
                return false
            }
        }
        
        return true
    }
    
    func postToFirebase(imgURL: String?) {
        
        var addProfileInfo: Dictionary<String, AnyObject> = [:]
        
        if defaults.valueForKey("username") != nil {
            addProfileInfo["username"] = defaults.valueForKey("username")
        }
        
        if imgURL != nil {
            addProfileInfo["profileimageurl"] = imgURL!
        }
        
        
        let firebaseProfile = DataService.ds.REF_USER_CURRENT
        firebaseProfile.setValue(addProfileInfo)
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        usernameTextField.resignFirstResponder()
        return true
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
