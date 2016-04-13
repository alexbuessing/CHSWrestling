//
//  ViewController.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/3/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailAddress: MaterialTextField!
    @IBOutlet var password: MaterialTextField!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    let network = Func()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailAddress.delegate = self
        password.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            
            loginSuccess()
        }
    }

    @IBAction func facebookLogin(sender: UIButton!) {
        
        let facebookLogin = FBSDKLoginManager()
        
        if network.connectedToNetwork() {
        facebookLogin.logInWithReadPermissions( [ "email" ], fromViewController: self ) { ( facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            if facebookError != nil {
                
                print( "Facebook login failed. Error: \( facebookError )" )
                
            } else {
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        //print("Logged in! \(authData)")
                        
                        let user = ["provider": authData.provider!, "username": ""]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.loginSuccess()
                    }
                })
            }
        }
        } else {
            showErrorAlert("No Network Connection", msg: "Please check you network connection and try again.")
        }
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailAddress.text where email != "", let pwd = password.text where pwd != "" {
            
            if network.connectedToNetwork() {
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                
                if error != nil {
                    print(error.code)
                    
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Please try again")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue([KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                                    
                                    let user = ["provider": authData.provider!, "username": ""]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
                                })
                                
                                self.loginSuccess()
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Could Not Login", msg: "Please check your username of password")
                    }
                    
                } else {
                    self.loginSuccess()
                }
                
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter and email and a password")
        }
        } else {
            showErrorAlert("No Network Connection", msg: "Please check you network connection and try again.")
        }
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailAddress.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
    
    func loginSuccess() {
        if self.defaults.valueForKey("username") != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        } else {
            self.performSegueWithIdentifier("profileSegue", sender: nil)
        }
    }

}

