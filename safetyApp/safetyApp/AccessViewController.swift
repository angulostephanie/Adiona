//
//  AccessViewController.swift
//  safetyApp
//
//  Created by Angela Chen on 7/27/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import AVFoundation
import Contacts
import Photos

class AccessViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var permissionText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var list = ""

        let locationStatus = CLLocationManager.authorizationStatus()
        if locationStatus != CLAuthorizationStatus.AuthorizedAlways {
            print("no location authorization")
            list = list + "•\tLocation Services"
        }
        
        let contactStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        if contactStatus != CNAuthorizationStatus.Authorized {
            print("no contact authorization")
            list = list + "\n•\tContact Book"
        }
        
        let cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if cameraStatus != AVAuthorizationStatus.Authorized {
            print("no camera authorization yet")
            list = list + "\n•\tCamera"
        }
        
        let micStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeAudio)
        if micStatus != AVAuthorizationStatus.Authorized {
            print("no camera authorization yet")
            list = list + "\n•\tMicrophone"
        }
        
        let cameraRollStatus = PHPhotoLibrary.authorizationStatus()
        if cameraRollStatus != PHAuthorizationStatus.Authorized {
            print("no camera roll authorization")
            list = list + "\n•\tPhoto Album"
        }
        
        print("permissions: \n\(list)")
        permissionText.text = String(list)
    }
    

    @IBAction func onOpenSettings(sender: AnyObject) {
        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsUrl {
            UIApplication.sharedApplication().openURL(url)
        }
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
