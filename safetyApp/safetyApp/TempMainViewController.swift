//
//  TempMainViewController.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/12/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage

class TempMainViewController: UIViewController {
    var user: User?
    @IBOutlet weak var pinNumLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTempPageView()

        // Do any additional setup after loading the view.
    }
    func setTempPageView() {
        let pin = PFUser.currentUser()!.objectForKey("pin") as! String
        //self.user?.pin
        
        let fbid = PFUser.currentUser()!.objectForKey("fbid") as! String
        let picUrl: NSURL = NSURL(string:"https://graph.facebook.com/\(fbid)/picture?type=large&return_ssl_resources=1")!
        pinNumLabel.text = pin
        profileImageView.af_setImageWithURL(picUrl)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func loadPosts() {
//        let query = PFQuery(className:"Post")
//        query.orderByDescending("createdAt")
//        query.includeKey("user")
//        query.limit = initialLimit
//        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error:NSError?) in
//            if error != nil {
//                print(error)
//            } else {
//                print("Successfully retrieved \(objects!.count) posts. - Home View Controller")
//                self.posts = objects
//                
//                //print("\(self.initialLimit) is now the limit")
//                self.tableView.reloadData()
//            }
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
