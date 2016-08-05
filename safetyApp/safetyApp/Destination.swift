//
//  Destination.swift
//  safetyApp
//
//  Created by Angela Chen on 7/11/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import GoogleMaps

class Destination: NSObject {
    
    var startCoords: CLLocationCoordinate2D!
    var endCoords: CLLocationCoordinate2D!
    var duration: String!
    var distance: String!
    var placeID: String!
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        let waypointArray = dictionary["geocoded_waypoints"] as! NSArray
        let waypoint = waypointArray[0] as! NSDictionary
        placeID = waypoint["place_id"] as! String
        
        let routesArray = dictionary["routes"] as! NSArray
        let routes = routesArray[0] as! NSDictionary
        
        let legs = (routes["legs"] as! NSArray)[0] as! NSDictionary
        
        let startLocation = legs["start_location"] as! NSDictionary
        let latS = startLocation["lat"] as! Double
        let langS = startLocation["lng"] as! Double
        startCoords = CLLocationCoordinate2DMake(CLLocationDegrees(latS), CLLocationDegrees(langS))
        
        let endLocation = legs["end_location"] as! NSDictionary
        let latE = endLocation["lat"] as! Double
        let langE = endLocation["lng"] as! Double
        endCoords = CLLocationCoordinate2DMake(CLLocationDegrees(latE), CLLocationDegrees(langE))
        
        let durationDict = legs["duration"] as! NSDictionary
        duration = durationDict["text"] as! String
        
        let distanceDict = legs["distance"] as! NSDictionary
        distance = distanceDict["text"] as! String
        
    }
}
