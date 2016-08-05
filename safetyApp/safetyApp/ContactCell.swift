//
//  ContactCell.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/22/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
