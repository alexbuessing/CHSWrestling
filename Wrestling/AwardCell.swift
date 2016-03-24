//
//  AwardCell.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/21/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class AwardCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var information: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(name: String, information: String) {
        
        self.name.text = name
        self.information.text = information
        
    }
    
}
