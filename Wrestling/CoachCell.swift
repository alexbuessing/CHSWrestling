//
//  CoachCell.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/14/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class CoachCell: UITableViewCell {

    @IBOutlet var coachImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var title: UILabel!
    
    var request: Request?

    override func drawRect(rect: CGRect) {
        
        coachImage.layer.cornerRadius = 3.0
        coachImage.clipsToBounds = true
        
    }
    
    func configureCell(imageURL: String, name: String, title: String) {
        
        self.name.text = name
        self.title.text = title
        
        request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, error in
            
            if error == nil {
                let img = UIImage(data: data!)!
                self.coachImage.image = img
            } else {
                print(error.debugDescription)
            }
            
        })
        
    }

}
