//
//  SettingsMenuVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage

class SettingsMenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var pictureView: UIImageView!
    
    var mainVC: MainViewController?
    var menuItems: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        /*let IDFromParse = PFUser.currentUser()!.objectForKey("fbid") as? String
        if let fbid = IDFromParse {
            if let url = NSURL(string: "https://graph.facebook.com/\(fbid)/picture?type=large&return_ssl_resources=1") {
                pictureView.af_setImageWithURL(url)
            }
        }*/
        
        menuItems = ["filter", "ID", "contacts", "pin", "check-in", "about", "logout"]
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.tintColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1.0)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        let IDFromParse = PFUser.currentUser()!.objectForKey("fbid") as? String
        if let fbid = IDFromParse {
            if let url = NSURL(string: "https://graph.facebook.com/\(fbid)/picture?type=large&return_ssl_resources=1") {
                pictureView.af_setImageWithURL(url)
                pictureView.layer.masksToBounds = true
                pictureView.layer.cornerRadius = pictureView.frame.height / 2
                pictureView.layer.borderWidth = 2.5
                pictureView.layer.borderColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0).CGColor
                pictureView.contentMode = UIViewContentMode.ScaleAspectFill
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = menuItems[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if menuItems[indexPath.row] == "logout" {
            let alertController = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                
            }
            let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive) { (action) in
                PFUser.logOutInBackgroundWithBlock { (error: NSError?) in }
                NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!) // remove saved filters
                print("logging out")
                self.performSegueWithIdentifier("unwindToLoginSegue", sender: nil)
                print("logged out")
            }
            // add the logout action to the alert controller
            alertController.addAction(logoutAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) {}
        } //need to link storyboards so that the app returns to the login vc upon logout
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filterSegue" {
            let vc = segue.destinationViewController as! FilterVC
            vc.mainVC = self.mainVC
        }
    }



}
