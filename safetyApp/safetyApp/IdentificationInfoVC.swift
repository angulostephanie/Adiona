//
//  IdentificationInfoVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse

class IdentificationInfoVC: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var hairColorField: UITextField!
    @IBOutlet weak var eyeColorField: UITextField!
    @IBOutlet weak var distinctiveFeaturesField: UITextField!
    @IBOutlet weak var pictureContainerView: UIView!
    @IBOutlet weak var birthdayField: UITextField!
    
    @IBOutlet weak var leftSideArrow: UIImageView!
    
    /* CONTRAINTS */
    let DEFAULT_BOTTOM_CONSTRAINT: CGFloat = 15
    var isKeyboardShown = false
    
    var originalCenter: CGFloat!
    var originalTop: CGFloat!
    
    @IBOutlet weak var fieldHeight: NSLayoutConstraint!
    @IBOutlet weak var nameFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pictureTopConstraint: NSLayoutConstraint!
    
    var pageVC: IDPicturePageVC?
    
    var keyToField: [String: UITextField]! // maps Parse keys to UITextFields
    var identificationInfo = NSMutableDictionary()
    var origPictures: [PFFile] = []
    var newPictures: [PFFile]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keyboard & Autolayout Details
        registerForKeyboardNotifications()
        originalCenter = self.view.frame.origin.y
        originalTop = pictureTopConstraint.constant
        
        // Set birthday to default
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
        leftSideArrow.transform = CGAffineTransformMakeScale(-1, 1)

        // load data from Parse
        let infoFromParse = PFUser.currentUser()!.objectForKey("identification_info") as? NSMutableDictionary
        
        keyToField = ["name": nameField, "age": ageField, "gender": genderField, "height": heightField, "birthday": birthdayField, "weight": weightField, "hair_color": hairColorField, "eye_color": eyeColorField, "distinctive_features": distinctiveFeaturesField]
        
        if let info = infoFromParse {
            identificationInfo = info
            
            for (key, field) in keyToField {
                if let info = identificationInfo[key] as? String {
                    field.text = info
                }
            }
            
            if birthdayField.text == "" {
                let birthday = PFUser.currentUser()!.objectForKey("birthday") as? String
                if let birthday = birthday {
                    birthdayField.text = dateFormatter.stringFromDate(NSDate(string: birthday, formatString: "MM/dd/yyyy"))
                }
            }
            
            origPictures = identificationInfo["pictures"] as? [PFFile] ?? []
        }
        
        
        // add picture page view controller
        pageVC = self.storyboard?.instantiateViewControllerWithIdentifier("picturePageController") as? IDPicturePageVC
        if let vc = pageVC {
            vc.view.frame = CGRectMake(0, 0, pictureContainerView.frame.size.width, pictureContainerView.frame.size.height)
            
            self.addChildViewController(vc)
            pictureContainerView.addSubview(vc.view)

            vc.pictures = origPictures
            vc.setInitialVC()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Only save data to Parse if the view is disappearing because (1) the back button in the navigation bar was pressed
        // (returning the user to the settings menu), or (2) the menu was closed altogether
        if self.isMovingFromParentViewController() || self.parentViewController!.isBeingDismissed() {
            // get current images
            if let vc = pageVC {
                newPictures = vc.pictures
            }
            
            if wasEdited() {
                // save text fields
                for (key, field) in keyToField {
                    
                    if let value = field.text {
                        identificationInfo[key] = value
                    } else {
                        identificationInfo[key] = ""
                    }
                }
                
                // save pictures
                if let pics = newPictures {
                    identificationInfo["pictures"] = pics
                } else {
                    identificationInfo["pictures"] = []
                }

                
                PFUser.currentUser()!.setObject(identificationInfo as NSDictionary, forKey: "identification_info")
                
                /*if let birthday = birthdayField.text {
                    PFUser.currentUser()!.setObject(birthday, forKey: "birthday")
                }*/
                
                PFUser.currentUser()!.saveInBackground()
            }
        }
    }
    
    @IBAction func birthdayTextFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        
        let birthday = birthdayField.text
        if let birthday = birthday {
            datePickerView.setDate(NSDate(string: birthday, formatString: "MM/dd/yyyy"), animated: false)
        }
        
        datePickerView.addTarget(self, action: #selector(IdentificationInfoVC.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }

    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        birthdayField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    func wasEdited() -> Bool {
        // check text fields
        for (key, field) in keyToField {
            if identificationInfo[key] as? String != field.text {
                return true
            }
        }
        
        // check pictures
        if let pics = newPictures {
            if pics != origPictures {
                return true
            }
        }
        
        return false
    }
    
    @IBAction func didTapView(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdentificationInfoVC.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(IdentificationInfoVC.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if self.isKeyboardShown {
            self.view.frame.origin.y = originalCenter
            nameFieldTopConstraint.constant = 0
            pictureTopConstraint.constant = originalTop
            
            self.view.layoutIfNeeded()
            self.isKeyboardShown = false
        }
    }

    func keyboardWasShown(notification: NSNotification) {
        if !self.isKeyboardShown {
            let userInfo = notification.userInfo
            let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
            let keyboardHeight = keyboardFrame.size.height
            
            let distanceFromBottom = self.view.frame.height - distinctiveFeaturesField.frame.origin.y - self.fieldHeight.constant
            let keyboardUp = abs(keyboardHeight - distanceFromBottom)
            self.view.frame.origin.y = -keyboardUp
            
            pictureTopConstraint.constant = -self.fieldHeight.constant
            nameFieldTopConstraint.constant = self.fieldHeight.constant
            
            self.view.layoutIfNeeded()
            self.isKeyboardShown = true
        }
    }

}
