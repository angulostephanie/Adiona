//
//  LoginViewController.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import ParseFacebookUtilsV4


class LoginViewController: UIViewController {
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (PFUser.currentUser() != nil && // Check if user is cached
            PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!)) { // Check if user is linked to Facebook
            print("User is already logged in ...")
        } else {
            print("User has yet to log in")
        }
    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
        
        
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        let permissionsArray = ["public_profile", "email", "user_birthday"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissionsArray, block: { (user: PFUser?, error: NSError?) in
            if let user = user {
                if user.isNew {
                    self.setUserData(true)
                    let defaults = NSUserDefaults.standardUserDefaults()
                    print("Hi new user! -- onLogin button")
                    defaults.setBool(true, forKey: "signedUp")
                    self.performSegueWithIdentifier("createPinSegue", sender: nil)
                } else {
                    self.setUserData(false)
                    print("Welcome back user! -- onLogin button")
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(true,forKey:"signedup")
                    self.performSegueWithIdentifier("enterPinSegue", sender: nil)
                }
            } else {
                print("user pressed cancel :( \(error?.localizedDescription)")
            }
        })
        
    }
    
    
    func setUserData(newUser: Bool) {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,gender,birthday,email,name, first_name, last_name, picture.width(720).height(720)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if (error == nil)
            {
                print("fetched user: \(result)")
                let currentUser = PFUser.currentUser()
                let fbUserDictionary = result as? NSDictionary
                self.user = User(dictionary: fbUserDictionary!)
                let picDictionary = fbUserDictionary!["picture"] as? NSDictionary
                let urlDictionary = picDictionary!["data"] as? NSDictionary
                
                self.user?.name = fbUserDictionary!["name"] as? String
                self.user?.email = fbUserDictionary!["email"] as? String
                self.user?.id = fbUserDictionary!["id"] as? String
                self.user?.fbid = fbUserDictionary!["id"] as? String
                self.user?.birthday = fbUserDictionary!["birthday"] as? String
                
                currentUser!.setObject(fbUserDictionary!["email"] as! String, forKey: "email")
                currentUser!.setObject(fbUserDictionary!["id"] as! String, forKey: "fbid")
                currentUser!.setObject(fbUserDictionary!["name"] as! String, forKey: "name")
                currentUser!.setObject(urlDictionary!["url"] as! String, forKey: "photo_url")
                currentUser!.setObject(fbUserDictionary!["birthday"] as! String, forKey: "birthday")
                
                if newUser {
                    let checkInSettings = NSMutableDictionary()
                    checkInSettings["call_police"] = CheckInSettings.callPoliceDefault
                    checkInSettings["message_contacts"] = CheckInSettings.messageContactsDefault
                    
                    currentUser!.setObject(checkInSettings as NSDictionary, forKey: "check_in_settings")
                    currentUser!.setObject(NSDictionary(), forKey: "identification_info")
                    currentUser!.setObject(NSArray(), forKey: "top_three")
                    currentUser!.saveInBackground()
                }
                
                User._currentUser = self.user
                
                print("welcome user: \(User._currentUser) --- set User Data func")
                print("\(User._currentUser?.name)")
                print("\(User._currentUser?.email)")
                print("\(User._currentUser?.fbid)")
            }
            else
            {
                print("Error: \(error)")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
