//
//  NewPermissionsViewController.swift
//  safetyApp
//
//  Created by Angela Chen on 7/27/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import AVFoundation
import Contacts
import Photos

class NewPermissionsViewController: UIViewController {
    
    var countPermissions: Int = 5
    let locationManager = CLLocationManager()

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLocationServices(sender: AnyObject) {
        
        locationManager.requestAlwaysAuthorization()
        
        showContinue(sender as! UIButton)
    }
    
    @IBAction func onContactBook(sender: AnyObject) {
        let addressBook = CNContactStore()
        addressBook.requestAccessForEntityType(CNEntityType.Contacts) { (Bool, error: NSError?) in
            // do nothing
        }
        
        showContinue(sender as! UIButton)
    }
    
    @IBAction func onCamera(sender: AnyObject) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
        
        showContinue(sender as! UIButton)
    }
    
    
    @IBAction func onMicrophone(sender: AnyObject) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio, completionHandler: nil)
        
        showContinue(sender as! UIButton)
    }
    
    @IBAction func onPhotoAlbum(sender: AnyObject) {
        PHPhotoLibrary.requestAuthorization { (PHAuthorizationStatus) in
            // idk
        }
        
        showContinue(sender as! UIButton)
        
    }
    
    func showContinue(button: UIButton) {
        countPermissions -= 1
        button.backgroundColor = UIColor(red: 0/255, green: 153/255, blue: 51/255, alpha: 1)
        button.userInteractionEnabled = false
        
        if countPermissions <= 0 {
            continueButton.hidden = false
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
