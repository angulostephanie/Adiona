//
//  Crime.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/21/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import GoogleMaps

class Crime: NSObject, GMUClusterItem {
    let type: String = "crime"
    
    let category: String
    let descript: String
    
    let time: NSDate? // incorporates both "date" and "time"
    
    let address: String
    let position: CLLocationCoordinate2D // location, but named "position" to conform to GMUClusterItem
    
    init(dict: NSDictionary) {
        address = dict["address"] as! String
        category = dict["category"] as! String
        descript = dict["descript"] as! String
        
        let locationDict = dict["location"] as! NSDictionary
        let coordinates = locationDict["coordinates"] as! NSArray
        position = CLLocationCoordinate2D(latitude: coordinates[1] as! Double, longitude: coordinates[0] as! Double)
        
        // ***TODO
        let dateString = dict["date"] as! String
        let trimmedDateString = dateString.stringByReplacingOccurrencesOfString("T00:00:00.000", withString: "")
        let timeString = dict["time"] as! String
        let dateTimeString = trimmedDateString + " " + timeString + " PT"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm v"
        time = dateFormatter.dateFromString(dateTimeString)
    }
}


/* Sample entry from API:
 {
    address = "5TH ST / BRYANT ST";
    category = WARRANTS;
    date = "2015-07-11T00:00:00.000";
    dayofweek = Saturday;
    descript = "ENROUTE TO OUTSIDE JURISDICTION";
    incidntnum = 150602980;
    location =         {
        coordinates =             (
            "-122.400302",
            "37.777799"
        );
        type = Point;
    };
    pddistrict = SOUTHERN;
    pdid = 15060298062050;
    resolution = "ARREST, BOOKED";
    time = "07:45";
    x = "-122.400302421513";
    y = "37.7777992290419";
 },
 */