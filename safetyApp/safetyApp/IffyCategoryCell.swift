//
//  IffyCategoryCell.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/30/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

class IffyCategoryCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    var category = "" {
        didSet {
            nameLabel.text = category
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
