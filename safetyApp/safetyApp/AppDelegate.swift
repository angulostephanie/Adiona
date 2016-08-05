//
//  AppDelegate.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/7/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import BDBOAuth1Manager
import Parse
import ParseUI
import ParseFacebookUtilsV4
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var APP_ID: String! = "SafetyApp"
    var MAP_API_KEY: String! = "AIzaSyACSrkVCTkCnwq6nSIC-y61ekWM0PbPk9s"
    var MASTER_KEY: String! = "ccldrbdgnfhttltljvjghnrnbferudkl"
    var DOMAIN: String! = "young-anchorage-48425.herokuapp.com"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //Parse.setApplicationId(“<Your Parse Application ID>", clientKey:”<Your Parse Client Key>")
        
        let config = ParseClientConfiguration(block: {
            (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = self.APP_ID
            ParseMutableClientConfiguration.clientKey = self.MASTER_KEY
            ParseMutableClientConfiguration.server = ("https://\(self.DOMAIN)/parse")
        })
        
        Parse.initializeWithConfiguration(config)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions);
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in
            //
        }
        GMSServices.provideAPIKey(MAP_API_KEY)
        GMSPlacesClient.provideAPIKey(MAP_API_KEY)
//        if PFUser.currentUser() != nil {
//            let navBar = (self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("navigationController"))! as UIViewController
//            self.window?.rootViewController = navBar
////            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
////            let mainScreenVC = mainStoryboard.instantiateViewControllerWithIdentifier("navigationController")
////            UIApplication.sharedApplication().keyWindow?.rootViewController = mainScreenVC;
//            
//            print("current user is still signed in")
//        } else {
//            let loginVC = (self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("loginVC"))! as UIViewController
//            self.window?.rootViewController = loginVC
//        }

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //self.saveContext() 
        //save app's object changes before app terminates
    }


}

