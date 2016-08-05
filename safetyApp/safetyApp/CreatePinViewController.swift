//
//  CreatePinViewController.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse

class CreatePinViewController: UIViewController, UITextFieldDelegate {
    var user: User?
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pinTextField.delegate = self
        continueButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        pinTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16.count + string.utf16.count - range.length
        return newLength <= 6
    }
    
    @IBAction func onTextEditing(sender: AnyObject) {
        if pinTextField.text?.characters.count == 6 {
            continueButton.hidden = false
        } else {
            continueButton.hidden = true
        }
    }
    
    
    @IBAction func onOk(sender: AnyObject) {
        let pin = pinTextField.text
        if pin?.characters.count == pinLength {
            User._currentUser?.pin = pin
            print("User's pin \(User._currentUser?.pin)")
            PFUser.currentUser()!.setObject(pin!, forKey: "pin")
            PFUser.currentUser()!.saveInBackground()
            self.performSegueWithIdentifier("approvalSegue", sender: nil)
            // self.performSegueWithIdentifier("mainScreenSegue", sender: nil)
        } else {
            print("Pin must be 6 characters long")
        }
        
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
