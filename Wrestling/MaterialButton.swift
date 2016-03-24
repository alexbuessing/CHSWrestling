//
//  MaterialButton.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/10/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

    override func awakeFromNib() {
        
        layer.cornerRadius = 3.0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
    }
    
}
