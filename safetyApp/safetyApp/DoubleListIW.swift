//
//  DoubeListIW.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/29/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

class DoubleListIW: UIView {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addViews(top: UIView, bottom: UIView) {
        topView.addSubview(top)
        bottomView.addSubview(bottom)
        
        setConstraints(top)
        setConstraints(bottom)
    }
    
    func setConstraints(view: UIView) {
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: view.superview, attribute: .Bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: view.superview, attribute: .Leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: view.superview, attribute: .Trailing, multiplier: 1, constant: 0)
        view.superview!.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }

}
