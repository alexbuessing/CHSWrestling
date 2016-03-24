//
//  ProfileVC.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/16/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Alamofire

class ProfileVC: UIViewController {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var jobTitle: UILabel!
    @IBOutlet var profileDescription: UITextView!
    @IBOutlet var biography: UILabel!
    var request: Request?
    var coach = Coach()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        getInfo(coach.profileImg)
    }
    
    func getInfo(imageURL: String) {
        
        name.text = coach.name
        jobTitle.text = coach.title
        profileDescription.text = coach.descrip
        biography.hidden = false
        
        request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, error in
            
            if error == nil {
                let img = UIImage(data: data!)!
                self.profileImage.image = img
            } else {
                print(error.debugDescription)
            }
        })
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        
        biography.hidden = true
        //performSegueWithIdentifier("showCoaches", sender: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
