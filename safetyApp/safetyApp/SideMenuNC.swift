//
//  SideMenuManager.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/29/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import SideMenu

protocol ButtonHandlerDelegate {
    func setUpContactButtons()
    func refreshCheckin()
}
class SideMenuNC: UISideMenuNavigationController {
   // var mainVC: MainViewController?
    
    var buttonDelegate: ButtonHandlerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed() {
            print ("dismissing menu")
            if (buttonDelegate != nil) {
                print("Buttons will be set up")
                print("Current top three \(User._currentUser!.contactsArray)")
                buttonDelegate!.setUpContactButtons()
                
                // Check-In Updates
                buttonDelegate!.refreshCheckin()
            } else {
                print("must add delegate to next view controller")
            }
            
        }
    }
    

}
