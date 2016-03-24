//
//  MaterialImageView.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/16/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class MaterialImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5.0
        self.clipsToBounds = true
        
    }

}
