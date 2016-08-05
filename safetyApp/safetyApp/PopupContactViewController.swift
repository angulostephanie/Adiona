//
//  PopupContactViewController.swift
//  safetyApp
//
//  Created by Angela Chen on 8/2/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

protocol DimDelegate {
    func dimScreen()
}

class PopupContactViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    var fullName: String!
    var phoneNumber: String!
    var delegate: DimDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = fullName

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCallButton(sender: AnyObject) {
        if let url = NSURL(string: "tel://\(phoneNumber!)") {
            UIApplication.sharedApplication().openURL(url)
            print("Calling \(fullName)")
        } else {
            print("Cannot call \(fullName)")
        }
        
        dismissViewControllerAnimated(false) { 
            self.delegate!.dimScreen()
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
