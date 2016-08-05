//
//  Location.swift
//  safetyApp
//
//  Created by Angela Chen on 7/12/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class Location: NSObject {
    var dictionary: NSDictionary?
    var address: String!
    var placeID: String!
    var placeName: String!
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        let resultsArray = dictionary["results"] as! NSArray
        let results = resultsArray[0] as! NSDictionary
        
        address = results["formatted_address"] as! String
        placeID = results["place_id"] as! String
    }
    
    class func getPlaceName(placeID: String, placesClient: GMSPlacesClient, success: (String) -> (), failure: (NSError) -> ()) {
        placesClient.lookUpPlaceID(placeID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                failure(error)
                return
            }
            
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place placeID \(place.placeID)")
                
                success(place.name)
            } else {
                success("No place details for \(placeID)")
            }
        })
    }
    
}