//
//  IffyViewController.swift
//  safetyApp
//
//  Created by Angela Chen on 7/20/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse

protocol IffyDelegate: class {
    func submitData(reasons: [String])
}

class IffyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var iffyTableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var iffyViewAlert: UIView!
    
    weak var delegate: IffyDelegate?
    
    //User's current location
    var currentLocation: CLLocationCoordinate2D!
    
    // Twilio
    let twilioAccountSID = "ACcdfffb6da68b6716f77f68baef989cdb"
    let twilioAuthToken = "3bab1ac80c3ccc8c206d487a614d727f"
    
    var otherText: String = ""
    // (iffies is a constant)
    var selectedCells = [NSIndexPath]()
    
    var otherTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        iffyTableView.delegate = self
        iffyTableView.dataSource = self
        iffyTableView.estimatedRowHeight = 50
        
        submitButton.userInteractionEnabled = false
        self.iffyViewAlert.transform = CGAffineTransformMakeScale(1.15, 1.15)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        UIView.animateWithDuration(0.2) {
            self.iffyViewAlert.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onIffyCancelButton(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onIffySubmitButton(sender: AnyObject) {
        var reasons: [String] = []
        
        // determine reasons from selected cells
        for indexPath in selectedCells {
            let parseKey = iffies[indexPath.row].key
            
            if parseKey == "other" {
                reasons.append(otherText)
            } else {
                reasons.append(parseKey)
            }
        }
        
        delegate?.submitData(reasons)
        
        view.endEditing(true)
        
        if (!(User._currentUser?.contactsArray.isEmpty)!) {
            var stringOfReasons = ""
            if reasons.count == 1 {
                stringOfReasons = reasons[0]
            } else {
                for i in 0 ..< reasons.count {
                    stringOfReasons = stringOfReasons + reasons[i] + ", "
                }
                stringOfReasons = String(stringOfReasons.characters.dropLast())
                stringOfReasons = String(stringOfReasons.characters.dropLast())
            }
            
            let firstMessage = "has inputted user data because they are not feeling safe"
            let iffyMessage = "'s reasons: \(stringOfReasons)"
            let clatitude = String(currentLocation.latitude)
            let clongitude = String(currentLocation.longitude)
            let currentLocationLink = "https://www.google.com/maps/preview/@\(clatitude),\(clongitude),16z"
            let currentLocationMessage = "'s current location: \(currentLocationLink)"
            
            sendAutomatedTextMessages(firstMessage)
            sendAutomatedTextMessages(iffyMessage)
            sendAutomatedTextMessages(currentLocationMessage)
        }
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iffies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IffyTableViewCell", forIndexPath: indexPath) as! IffyTableViewCell
        
        cell.accessoryType = selectedCells.contains(indexPath) ? .Checkmark : .None
        cell.descriptionTextField.delegate = self
        
        if (indexPath.row != iffies.count - 1) {
            cell.descriptionTextField.text = iffies[indexPath.row].label
            cell.descriptionTextField.userInteractionEnabled = false
        } else {
            otherTextField = cell.descriptionTextField
            otherTextField.text = otherText
            otherTextField.placeholder = "Other (e.g. Beast the Puli)"
        }
        
        return cell
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.userInteractionEnabled = false
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        otherText = textField.text!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! IffyTableViewCell
        
        if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            if indexPath.row == iffies.count - 1 {
                otherText = ""
                otherTextField.text = otherText
                otherTextField.placeholder = "Other (e.g. Beast)"
                otherTextField.userInteractionEnabled = false
                view.endEditing(true)
            }
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            selectedCells = selectedCells.filter {$0 != indexPath}
            
        } else {
            if indexPath.row == iffies.count - 1 {
                otherTextField.text = otherText
                otherTextField.userInteractionEnabled = true
                otherTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
            
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedCells.append(indexPath)
        }
        
        if selectedCells.count > 0 {
            submitButton.userInteractionEnabled = true
            submitButton.titleLabel?.textColor = submitButton.tintColor
        } else {
            submitButton.userInteractionEnabled = false
            submitButton.titleLabel?.textColor = UIColor.grayColor()
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
}
