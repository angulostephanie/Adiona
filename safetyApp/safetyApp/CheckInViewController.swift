//
//  Pin2ViewController.swift
//  cameraTester
//
//  Created by Angela Chen on 7/28/16.
//  Copyright © 2016 Angela Chen. All rights reserved.
//

import UIKit
import Parse
import SwiftRequest

protocol PopupDelegate {
    func tripEnded(ended: Bool)
    func restartTimer()
}

class CheckInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var okAlert: UIView!
    
    var delegate: PopupDelegate?
    
    //User's current location
    var currentLocation: CLLocationCoordinate2D!
    
    // Twilio
    let twilioAccountSID = "ACcdfffb6da68b6716f77f68baef989cdb"
    let twilioAuthToken = "3bab1ac80c3ccc8c206d487a614d727f"
    
    
    var checkInSettings: NSDictionary?
    var messageContacts: Bool?
    var callPolice: Bool?
    var timer: NSTimer!
    var seconds = 60
    
    var failedPinCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkInSettings = PFUser.currentUser()!.objectForKey("check_in_settings") as? NSDictionary
        messageContacts = checkInSettings!["message_contacts"] as? Bool
        callPolice = checkInSettings!["call_police"] as? Bool
        
        pinTextField.delegate = self
        
        okAlert.transform = CGAffineTransformMakeScale(1.15, 1.15)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(CheckInViewController.updateTime), userInfo: nil, repeats: true)
        
    }
    
    func updateTime() {
        seconds -= 1

        if seconds > 0 {
            if seconds != 1 {
                secondsLabel.text = "\(seconds) seconds remaining"
            } else {
                secondsLabel.text = "\(seconds) second remaining"
            }
        } else if seconds == 0 {
            timer.invalidate()
            
            secondsLabel.text = ""
            descriptionLabel.text = "You didn't respond on time, so we have contacted your chosen emergency contacts. Please type in your PIN number to let them know that you're okay."
            
            if (messageContacts == true) {
                
                let noCheckInMessage = " did not check in on time. Go make sure they are okay."
                let clatitude = String(currentLocation.latitude)
                let clongitude = String(currentLocation.longitude)
                let currentLocationLink = "https://www.google.com/maps/preview/@\(clatitude),\(clongitude),16z"
                let currentLocationMessage = "'s current location: \(currentLocationLink)"
                
                sendAutomatedTextMessages(noCheckInMessage)
                sendAutomatedTextMessages(currentLocationMessage)
            }
            
            if (callPolice == true) {
                if let url = NSURL(string: "tel://\(8175865956)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            
            seconds -= 1
            
        } else {
            timer.invalidate()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        pinTextField.becomeFirstResponder()
        
        UIView.animateWithDuration(0.2) {
            self.okAlert.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        pinTextField.resignFirstResponder()
        
        timer.invalidate()
        // delegate?.restartTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16.count + string.utf16.count - range.length
        return newLength <= 6
    }
    
    @IBAction func onTextEditing(sender: AnyObject) {
        pinTextField.attributedText = letterSpacing(pinTextField.text!, spacing: 5.0)
        
        if pinTextField.text?.characters.count == 6 {
            if pinCorrect() {
                timer.invalidate()
                let successfulCheckInMessage = "has recently checked in and is still travelling."
                let clatitude = String(currentLocation.latitude)
                let clongitude = String(currentLocation.longitude)
                let currentLocationLink = "https://www.google.com/maps/preview/@\(clatitude),\(clongitude),16z"
                let currentLocationMessage = "'s check in location: \(currentLocationLink)"
                sendAutomatedTextMessages(successfulCheckInMessage)
                sendAutomatedTextMessages(currentLocationMessage)
                
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.pinTextField.textColor = UIColor.redColor()
                failedPinCount += 1
                
                self.pinTextField.alpha = 0
                UIView.animateWithDuration(0.2, delay: 0.0, options: [UIViewAnimationOptions.Autoreverse], animations: {
                    self.pinTextField.alpha = 1.0
                    }, completion: nil)
                
                if failedPinCount > 3 {
                    print("TEXT CONTACTS HERE")
                    let unsuccessfulCheckInMessage = "has tried to checked in and was unsuccessful. Go check on them."
                    let clatitude = String(currentLocation.latitude)
                    let clongitude = String(currentLocation.longitude)
                    let currentLocationLink = "https://www.google.com/maps/preview/@\(clatitude),\(clongitude),16z"
                    let currentLocationMessage = "'s current location: \(currentLocationLink)"
                    sendAutomatedTextMessages(unsuccessfulCheckInMessage)
                    sendAutomatedTextMessages(currentLocationMessage)
                }
            }
        } else {
            pinTextField.layer.removeAllAnimations()
            pinTextField.textColor = UIColor.blackColor()
        }
    }
    
    @IBAction func onEmergencyButton(sender: AnyObject) {
        timer.invalidate()
        
        if let url = NSURL(string: "tel://\(6505214958)") {
            UIApplication.sharedApplication().openURL(url)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pinCorrect() -> Bool {
        print("\(User._currentUser!.name)")
        let enteredPin = pinTextField.text
        let actualPin = PFUser.currentUser()!.objectForKey("pin") as! String
        //check if pin text matches with user's pin
        if enteredPin == actualPin {
            User._currentUser!.pin = PFUser.currentUser()!.objectForKey("pin") as! String
            print("User object says the pin is: \(User._currentUser?.pin)")
            
            print("correct pin! on to main screen :)")
            return true
            
        } else {
            print("incorrect pin, sorry!")
            //add alert
            return false
        }
    }
    
    /********* AUTOMATED TEXT MESSAGES *********/
    func sendAutomatedTextMessages(message: String) {
        for i in 0 ..< User._currentUser!.contactsArray.count {
            let fullName = (User._currentUser?.contactsArray[i].keys.first!)! as String
            let fullNameArr = fullName.componentsSeparatedByString(" ")
            let firstName = fullNameArr[0]
            var phoneNumber = User._currentUser?.contactsArray[i][fullName]
            if (String(phoneNumber![(phoneNumber?.startIndex.advancedBy(0))!]) != "1") {
                phoneNumber = "1" + phoneNumber!
            }
            twilioAPICall(phoneNumber!, contactName: firstName, message: message)
        }
    }
    
    func twilioAPICall(phoneNumber: String, contactName: String, message: String) {
        //Message needs to be changed to have the user's current location and desired final destination
        let fullNameArr = User._currentUser?.name!.componentsSeparatedByString(" ")
        let userFirstName = fullNameArr![0]
        let toNumber = "%2B\(phoneNumber)"
        let greeting = "Yo \(contactName), \(userFirstName) "
        
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioAccountSID):\(twilioAuthToken)@api.twilio.com/2010-04-01/Accounts/\(twilioAccountSID)/SMS/Messages")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "From=%2B15106803810&To=\(toNumber)&Body=\(greeting+message)".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Build the completion block and send the request
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            print("Finished")
            if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                // Success
                print("Response: \(responseDetails)")
                print("Success")
                //                dispatch_async(dispatch_get_main_queue()) {
                //
                //                }
                
            } else {
                // Failure
                print("Error: \(error)")
                //                dispatch_async(dispatch_get_main_queue()) {
                //
                //                }
            }
        }).resume()
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
