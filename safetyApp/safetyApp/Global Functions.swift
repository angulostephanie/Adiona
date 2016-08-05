//
//  Global Functions.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/18/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import Foundation
import ParseUI

// Convert UIImage to PFFile to store in Parse
func getPFFileFromImage(image: UIImage?) -> PFFile? {
    // check if image is not nil
    if let image = image {
        // get image data and check if that is not nil
        if let imageData = UIImagePNGRepresentation(image) {
            return PFFile(name: "image.png", data: imageData)
        }
    }
    return nil
}

// Shows a basic alert controller on the caller view controller, with a single "okay" button that does nothing when clicked.
func showBasicAlert(caller: UIViewController, title: String?, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
    alertController.addAction(okayAction)
    caller.presentViewController(alertController, animated: true, completion: nil)
}

// Design: Adjusts letter spacing
func letterSpacing(string:String, spacing: CGFloat) -> NSMutableAttributedString {
    let attributedStr = NSMutableAttributedString(string: string)
    attributedStr.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, attributedStr.length))
    return attributedStr
}