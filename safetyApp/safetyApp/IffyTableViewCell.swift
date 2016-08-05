//
//  IffyTableViewCell.swift
//  safetyApp
//
//  Created by Angela Chen on 7/19/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

class IffyTableViewCell: UITableViewCell {

    @IBOutlet weak var otherTextView: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
