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
import MBProgressHUD

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
            
            let urlString = "https://post.imageshack.us/upload_api.php"
            let url = NSURL(string: urlString)!
            let imageData = UIImageJPEGRepresentation(img, 0.3)!
            let keyData = "59DERUWY4e7ad4a26bedc73667d1847f36c7c5fd".dataUsingEncoding(NSUTF8StringEncoding)!
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
            
            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                multipartFormData.appendBodyPart(data: keyData, name: "key")
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
            }) { encodingResult in
                //This is what happens when the encoding is done
                
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { response in
                        if let info = response.result.value as? Dictionary<String, AnyObject> {
                            if let links = info["links"] as? Dictionary<String, AnyObject> {
                                if let imageLink = links["image_link"] as? String {
                                    self.defaults.setObject(imageLink, forKey: "profileURL")
                                }
                            }
                        }
                    })
                case .Failure(let error):
                    print(error)
                }
            }
            
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
