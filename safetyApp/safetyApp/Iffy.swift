//
//  Safety Data.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/19/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

class Iffy: NSObject, GMUClusterItem {
    static var _filteredCategories: [String: Bool]?
    
    let type = "iffy"
    
    let position: CLLocationCoordinate2D // location, but named "position" to conform to GMUClusterItem
    let locationAsDict: NSDictionary
    
    var time: NSDate? = nil // incorporates both date and time
    let reasons: NSDictionary
    var filteredReasons: NSDictionary!
    
    var filteredOut: Bool = false // if true, this object has been filtered out and should not be displayed
    
    // used to create data when user feels unsafe
    // reasons should be an array of parse keys (see iffies array in Constants)
    // "time" is not set in this init method, but if postToParse follows an init, then "time" will be set
    init(location: CLLocationCoordinate2D, reasons userReasons: [String]) {
        self.position = location
        self.locationAsDict = ["lat": location.latitude as Double, "long": location.longitude as Double]
        
        // create default reasons dictionary
        let mutableReasons = NSMutableDictionary()
        for i in 0..<(iffies.count - 1) { // exclude "other", since not Bool
            mutableReasons[iffies[i].key] = false
        }
        mutableReasons["other"] = ""
        
        // populate with user's actual reasons
        var found = false
        for userReason in userReasons {
            // search for user's reason in the array of all possible reasons, excluding "other"
            for i in 0..<(iffies.count - 1) {
                let parseKey = iffies[i].key
                if userReason == parseKey {
                    // this reason was a reason the user chose
                    mutableReasons[parseKey] = true
                    found = true
                    break
                }
            }
            
            if !found {
                mutableReasons["other"] = userReason
            }
        }
        
        self.reasons = mutableReasons
        
        super.init()
        
        filterOut()
    }
    
    // used when data is pulled from server
    init(object: PFObject) {
        self.locationAsDict = object["location"] as! NSDictionary
        self.position = CLLocationCoordinate2D(latitude: (locationAsDict["lat"] as! CLLocationDegrees), longitude: (locationAsDict["long"] as! CLLocationDegrees))
        self.reasons = object["reasons"] as! NSDictionary
        
        super.init()
        
        filterOut()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm v"
        
        time = object.createdAt
    }
    
    func filterOut() {
        // set filteredReasons
        let mutableFiltered = NSMutableDictionary()
        guard let categories = Iffy._filteredCategories else {
            self.filteredReasons = self.reasons
            return
        }
        
        for (category, value) in categories {
            if value {
                mutableFiltered[category] = reasons[category]
            }

        }
        
        self.filteredReasons = mutableFiltered
        
        // determine if the object should be filtered out entirely
        for (_, value) in filteredReasons {
            if let value = value as? Bool where value {
                return // filteredOut should stay false if any value is true
            }
        }
        // object is filtered out if none of its reasons are a filtered reason
        filteredOut = true
    }
    
    // saves the object to Parse
    // also sets "time" from createdAt if it hasn't been set yet
    func postToParse(completion: PFBooleanResultBlock?) {
        let data = PFObject(className: "Safety_Data")
        data["location"] = locationAsDict
        data["reasons"] = reasons
        data.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if success {
                self.time = data.createdAt
            }

            if let completion = completion {
                completion(success, error)
            }

        }
    }
}
