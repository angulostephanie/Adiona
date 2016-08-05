//
//  CheckInSettingsVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse

class CheckInSettingsVC: UIViewController {

    @IBOutlet weak var policeSwitch: UISwitch!
    @IBOutlet weak var contactsSwitch: UISwitch!
    @IBOutlet weak var checkinMinTextField: UITextField!
    
    var checkInSettings = NSMutableDictionary()
    var originalCenter: CGFloat!
    var isKeyboardShown = false
    
    @IBOutlet weak var moveView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        originalCenter = self.view.frame.origin.y
        
        // load data from Parse
        let settingsFromParse = PFUser.currentUser()!.objectForKey("check_in_settings") as? NSMutableDictionary
        
        if let settings = settingsFromParse {
            checkInSettings = settings
        }
        
        if let police = checkInSettings["call_police"] as? Bool {
            policeSwitch.on = police
        } else {
            policeSwitch.on = CheckInSettings.callPoliceDefault
            checkInSettings["call_police"] = CheckInSettings.callPoliceDefault
        }
        
        if let contacts = checkInSettings["message_contacts"] as? Bool {
            contactsSwitch.on = contacts
        } else {
            contactsSwitch.on = CheckInSettings.messageContactsDefault
            checkInSettings["message_contacts"] = CheckInSettings.messageContactsDefault
        }
        
        if let minutes = checkInSettings["check_time"] as? String {
            checkinMinTextField.text = minutes
        } else {
            checkinMinTextField.text = String(CheckInSettings.checkInTimeDefault)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if wasEdited() {
            // save data to Parse
            checkInSettings["call_police"] = policeSwitch.on
            checkInSettings["message_contacts"] = contactsSwitch.on
            
            if let minutes = checkinMinTextField.text {
                checkInSettings["check_time"] = minutes
            }
            
            PFUser.currentUser()!.setObject(checkInSettings as NSDictionary, forKey: "check_in_settings")
            PFUser.currentUser()!.saveInBackground()
        }
    }
    
    func wasEdited() -> Bool {
        let police = checkInSettings["call_police"] as? Bool
        let contacts = checkInSettings["message_contacts"] as? Bool
        
        if let police = police {
            if police != policeSwitch.on {
                return true
            }
        } else {
            return true
        }
        
        if let contacts = contacts {
            if contacts != contactsSwitch.on {
                return true
            }
        } else {
            return true
        }
        
        if checkInSettings["check_time"] as? String != checkinMinTextField.text {
            return true
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
    
    
    func deregisterFromKeyboardNotifications() {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if self.isKeyboardShown {
            self.view.frame.origin.y = originalCenter
            
            self.view.layoutIfNeeded()
            self.isKeyboardShown = false
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        if !self.isKeyboardShown {
            let userInfo = notification.userInfo
            let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
            let keyboardHeight = keyboardFrame.size.height
            
            print("move view: \(moveView.frame.origin.y)")
            let distanceFromBottom = self.view.frame.height - moveView.frame.origin.y - moveView.frame.height
            self.view.frame.origin.y = -abs(keyboardHeight - distanceFromBottom)
            
            self.view.layoutIfNeeded()
            self.isKeyboardShown = true
        }
    }

    /*
     Load from Parse.
     Save to Parse.
    */

}
