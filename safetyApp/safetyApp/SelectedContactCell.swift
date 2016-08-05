//
//  SelectedContactCell.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/11/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

class SelectedContactCell: UITableViewCell {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!

    
    // ***TODO: var contact: Contact?
    var removeHandler: ((cell: SelectedContactCell) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // ***TODO: populate fields with contact info
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didPressRemove(sender: AnyObject) {
        if let handler = removeHandler {
            handler(cell: self)
        }
        
    }
}
