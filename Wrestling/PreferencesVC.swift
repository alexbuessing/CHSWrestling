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
    
    override func viewWillAppear(animated: Bool) {
        if self.defaults.valueForKey("username") != nil {
            cancelButton.hidden = false
        } else {
            cancelButton.hidden = true
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
        profileImage.image = image
        clickLabel.hidden = true
        imageSelected = true
        
    }
    
    @IBAction func saveUserInfo(sender: AnyObject) {
        
        if let txt = usernameTextField.text where txt != "" {
            
            defaults.setObject(txt, forKey: "username")
            
            if let img = profileImage.image where imageSelected == true {
                
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                let imageData = UIImageJPEGRepresentation(img, 0.3)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                    }) { encodingResult in
                        
                        switch encodingResult {
                        case .Success(let upload,_,_):
                            upload.responseJSON(completionHandler: { response in
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imageLink = links["image_link"] as? String {
                                            self.postToFirebase(imageLink)
                                            self.performSegueWithIdentifier("segueToFeed", sender: nil)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                }
                
            } else {
                self.postToFirebase(nil)
            }
            
        }

    }
    
    func postToFirebase(imgURL: String?) {
        
        var addProfileInfo: Dictionary<String, AnyObject> = ["username": usernameTextField.text!]
        
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
    
}
