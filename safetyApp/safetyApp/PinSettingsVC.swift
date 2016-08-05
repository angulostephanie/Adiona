//
//  PinSettingsVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse

class PinSettingsVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var currentPinField: UITextField!
    @IBOutlet weak var newPinField: UITextField!
    @IBOutlet weak var newPinField2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPinField.delegate = self
        newPinField.delegate = self
        newPinField2.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // restricts maximum number of characters allowed in the text field
        let currentCharCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharCount) {
            return false
        }
        
        let newLength = currentCharCount + string.characters.count - range.length
        
        return newLength <= pinLength
    }
    
    @IBAction func didTapView(sender: AnyObject) {
        // dismiss keyboard
        view.endEditing(true)
    }
    
    @IBAction func didPressSubmit(sender: AnyObject) {
        // check all the text fields are populated with strings of the correct length
        if !(currentPinField.text?.characters.count == pinLength && newPinField.text?.characters.count == pinLength && newPinField2.text?.characters.count == pinLength) {
            // show warning: fields populated incorrectly
            showBasicAlert(self, title: "Invalid Entry", message: "All fields must be filled with pins of length \(pinLength).")
            return
        }
        
        // check entered current pin against Parse info
        let currentPin = PFUser.currentUser()!.objectForKey("pin") as! String
        print("current pin: \(currentPin)")
        if currentPinField.text! != currentPin {
            // show warning: entered wrong current pin
            showBasicAlert(self, title: "Wrong Pin", message: "The pin you entered does not match your current pin.")
            return
        }
        
        // check both new pin fields have the same pin
        if newPinField.text != newPinField2.text {
            // show warning: fields don't match
            showBasicAlert(self, title: "Fields Don't Match", message: "The two new pin fields must have the same pin.")
            return
        }
        
        // if passes all checks, save new pin to Parse
        PFUser.currentUser()!.setObject(newPinField.text!, forKey: "pin")
        PFUser.currentUser()!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if success {
                // alert that pin has been changed
                showBasicAlert(self, title: "Success!", message: "Pin has been successfully changed.")
                
                // reset screen
                self.currentPinField.text = nil
                self.newPinField.text = nil
                self.newPinField2.text = nil
                self.view.endEditing(true)
            } else {
                // alert error in saving pin
                showBasicAlert(self, title: "Error", message: "New pin failed to save. Please try again.")
                return
            }
        }
    }
    

}
