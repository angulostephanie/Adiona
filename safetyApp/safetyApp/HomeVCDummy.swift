//
//  HomeVCDummy.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import SideMenu

class HomeVCDummy: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuLeftNavC = UISideMenuNavigationController()
        menuLeftNavC.leftSide = true
        SideMenuManager.menuLeftNavigationController = menuLeftNavC
        
        let menuRightNavC = UISideMenuNavigationController()
        SideMenuManager.menuRightNavigationController = menuRightNavC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func menuButton(sender: AnyObject) {
        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
}
