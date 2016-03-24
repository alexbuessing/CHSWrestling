//
//  HeaderCell.swift
//  Wrestling
//
//  Created by Alexander Buessing on 3/21/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {

    @IBOutlet var sectionTitle: UILabel!
    @IBOutlet var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5.0
        containerView.layer.borderColor = UIColor.blackColor().CGColor
        containerView.layer.borderWidth = 2.0
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(title: String) {
        
        self.sectionTitle.text = title
        
    }
    
}
