//
//  ScheduleCell.swift
//  Wrestling
//
//  Created by Alexander Buessing on 4/6/16.
//  Copyright © 2016 Buessing. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {

    @IBOutlet var eventDescription: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(eventDescription: String, location: String, time: String, date: String) {
        
        
        self.eventDescription.text = eventDescription
        self.date.text = date
        self.time.text = time
        self.location.text = location
        
    }

}
