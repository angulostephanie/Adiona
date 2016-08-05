//
//  EnterPinViewController.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage
import Contacts
import Photos
import AVFoundation

class EnterPinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pinTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Parse says the user's pin is: \(PFUser.currentUser()!.objectForKey("pin") as! String)")
        
        pinTextField.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        pinTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
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
        if pinTextField.text?.characters.count == 6 {
            if pinCorrect() {
                if permissionsGranted() {
                    self.performSegueWithIdentifier("mainScreenSegue", sender: nil)
                }
                else {
                    self.performSegueWithIdentifier("accessSegue", sender: nil)
                }
            } else {
                self.pinTextField.textColor = UIColor(red: 100/255, green: 0/255, blue: 0/255, alpha: 1)
                
                self.pinTextField.alpha = 0
                UIView.animateWithDuration(0.2, delay: 0.0, options: [UIViewAnimationOptions.Autoreverse], animations: {
                    self.pinTextField.alpha = 1.0
                    }, completion: nil)
            }
        } else {
            pinTextField.layer.removeAllAnimations()
            pinTextField.layer.borderWidth = 0
            pinTextField.textColor = UIColor.whiteColor()
        }
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
    
    func permissionsGranted() -> Bool {
        let locationStatus = CLLocationManager.authorizationStatus()
        if locationStatus != CLAuthorizationStatus.AuthorizedAlways {
            return false
        }
        
        let contactStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        if contactStatus != CNAuthorizationStatus.Authorized {
            return false
        }
        
        let cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if cameraStatus != AVAuthorizationStatus.Authorized {
            return false
        }
        
        let micStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeAudio)
        if micStatus != AVAuthorizationStatus.Authorized {
            return false
        }
        
        let cameraRollStatus = PHPhotoLibrary.authorizationStatus()
        if cameraRollStatus != PHAuthorizationStatus.Authorized {
            return false
        }
        
        return true
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
