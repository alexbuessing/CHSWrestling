//
//  MaterialTextField.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/10/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    override func awakeFromNib() {
        
        layer.cornerRadius = 3.0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1.0
//        layer.borderColor = UIColor.blackColor().CGColor
//        layer.shadowOpacity = 0.3
//        layer.shadowRadius = 5.0
//        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10.0, 0.0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10.0, 0.0)
    }
    
}
