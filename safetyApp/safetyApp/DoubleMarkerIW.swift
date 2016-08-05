//
//  DoubleMarkerIW.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/28/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

class DoubleMarkerIW: UIView {

    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        leftView.translatesAutoresizingMaskIntoConstraints = false
        rightView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addViews(left: UIView, right: UIView) {
        leftView.addSubview(left)
        rightView.addSubview(right)
        
        setConstraints(left)
        setConstraints(right)
    }
    
    func setConstraints(view: UIView) {
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: view.superview, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: view.superview, attribute: .Bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: view.superview, attribute: .Leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: view.superview, attribute: .Trailing, multiplier: 1, constant: 0)
        view.superview!.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
    }
}
