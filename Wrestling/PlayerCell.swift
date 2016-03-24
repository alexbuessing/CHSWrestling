//
//  PlayerCell.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/16/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit
import Alamofire

class PlayerCell: UICollectionViewCell {
    
    @IBOutlet var playerImage: UIImageView!
    @IBOutlet var playerName: UILabel!
    @IBOutlet var playerWeight: UILabel!
    @IBOutlet var playerRecord: UILabel!
    
    var request: Request?
    
    override func awakeFromNib() {
        layer.cornerRadius = 5.0
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func configureCell(imageURL: String, name: String, weight: String, year: String, record: String) {
        
        playerName.text = "\(name), \(year)"
        playerWeight.text = weight
        playerRecord.text = record
        
        request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, error in
            
            if error == nil {
                let img = UIImage(data: data!)!
                self.playerImage.image = img
            } else {
                print(error.debugDescription)
            }
            
        })
        
    }
    
}
