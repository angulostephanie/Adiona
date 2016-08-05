//
//  MapClient.swift
//  safetyApp
//
//  Created by Angela Chen on 7/11/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import GoogleMaps

class MapClient {
    
    let BASE_URL: String = "https://maps.googleapis.com/maps/api/"
    let iOS_KEY: String = "AIzaSyACSrkVCTkCnwq6nSIC-y61ekWM0PbPk9s"
    let SERVER_KEY: String = "AIzaSyA3UTvyMBZRPdxSGpRfT3AA8pRvF1PWt_M"
    
    static let sharedInstance = MapClient()
    
    func directionFrom(start: CLLocationCoordinate2D, destination: String, success: (Destination) -> (), failure: (NSError) -> ()) {
        let  origin = "\(NSNumber(double: start.latitude)),\(NSNumber(double: start.longitude))"
        let destination = destination.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let urlPath: String = "\(BASE_URL)directions/json?origin=\(origin)&destination=\(destination)&mode=walking&key=\(SERVER_KEY)"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    //print("Information \(jsonResult)")
                    
                    if (jsonResult["status"] as! String) == String("ZERO_RESULTS") {
                        let userInfo: [NSObject : AnyObject] =
                        [
                            NSLocalizedDescriptionKey :  NSLocalizedString("Nonexistent", value: "No route found between locations.", comment: ""),
                            NSLocalizedFailureReasonErrorKey : NSLocalizedString("Nonexistent", value: "No route found between locations.", comment: "")
                        ]
                        let noExistError = NSError(domain: "com.fbu.safetyApp", code: -42, userInfo: userInfo)
                        failure(noExistError)
                        return
                    }
                    
                    let info = Destination(dictionary: jsonResult)
                    success(info)
                }
            } catch let error as NSError {
                failure(error)
            }
        }
        
        task.resume()
        
    }
    
    func getLocationFromCoords(coords: CLLocationCoordinate2D, success: (Location) -> (), failure: (NSError) -> ()) {
        let location = "\(NSNumber(double: coords.latitude)),\(NSNumber(double: coords.longitude))"
        networkingGetLocation(location, success: { (location: Location) in
            success(location)
        }) { (error: NSError) in
            failure(error)
        }
        
    }
    
    func getLocationFromLongLat(latitude: String, longitude: String, success: (Location) -> (), failure: (NSError) -> ()) {
        let location = "\(latitude),\(longitude)"
        networkingGetLocation(location, success: { (location: Location) in
            success(location)
        }) { (error: NSError) in
            failure(error)
        }
    }
    
    private func networkingGetLocation(location: String, success: (Location) -> (), failure: (NSError) -> ()) {
        
        let urlPath: String = "\(BASE_URL)geocode/json?latlng=\(location)&key=\(iOS_KEY)"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    //print("Geocode \(jsonResult)")
                    
                    if (jsonResult["status"] as! String) == String("ZERO_RESULTS") {
                        let userInfo: [NSObject : AnyObject] =
                            [
                                NSLocalizedDescriptionKey :  NSLocalizedString("Nonexistent", value: "No location found from coordinates.", comment: ""),
                                NSLocalizedFailureReasonErrorKey : NSLocalizedString("Nonexistent", value: "No location found from coordinates.", comment: "")
                        ]
                        let noExistError = NSError(domain: "com.fbu.safetyApp", code: -43, userInfo: userInfo)
                        failure(noExistError)
                        return
                    }
                    
                    let info = Location(dictionary: jsonResult)
                    success(info)
                }
            } catch let error as NSError {
                failure(error)
            }
        }
        
        task.resume()
    }
    
    

}
