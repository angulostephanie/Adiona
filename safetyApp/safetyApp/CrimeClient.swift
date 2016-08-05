//
//  CrimeClient.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/21/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import DateTools

class CrimeClient {
    class func getData(categories: [String: Bool], completion: ((crimes: [Crime]) -> ())){
        var crimes: [Crime] = []
        
        let appToken = "flr5w8LLzMlcdkvyt2irFrcpy"
        //let categories = ["KIDNAPPING", "ROBBERY"] // categories where all descriptions are included
        let numMonths = 3
        
        var urlString = "https://data.sfgov.org/resource/cuks-n6tp.json?"
        urlString += "$$app_token=\(appToken)"
        
        var whereString = "&$where="
        
        // category
        var categoriesString = ""
        /*for cat in categories {
            if categoriesString != "" {
                categoriesString += ", "
            }
            categoriesString += "'\(cat)'"
        }
        categoriesString = "(category in (\(categoriesString)))"
        
        // filter category 'secondary codes'
        categoriesString += " OR (category = 'SECONDARY CODES' AND descript in ('GANG ACTIVITY', 'PREJUDICE-BASED INCIDENT'))"
        
        // filter category 'assault'
        categoriesString += " OR (category = 'ASSAULT' AND (descript not in ('INFLICT INJURY ON COHABITEE', 'BATTERY, FORMER SPOUSE OR DATING RELATIONSHIP', 'ELDER ADULT OR DEPENDENT ABUSE (NOT EMBEZZLEMENT OR THEFT)', 'THREATENING PHONE CALL(S)')))"
        
        // filter category 'sex offenses, forcible'
        categoriesString += " OR (category = 'SEX OFFENSES, FORCIBLE' AND (descript not in ('CHILD ABUSE, PORNOGRAPHY', 'RAPE, SPOUSAL')))"*/
        
        for (category, value) in categories {
            if value {
                if categoriesString != "" {
                    categoriesString += " OR "
                }
                
                if category == "SECONDARY CODES" {
                    categoriesString += "(category = 'SECONDARY CODES' AND descript in ('GANG ACTIVITY', 'PREJUDICE-BASED INCIDENT'))"
                } else if category == "ASSAULT" {
                    categoriesString += "(category = 'ASSAULT' AND (descript not in ('INFLICT INJURY ON COHABITEE', 'BATTERY, FORMER SPOUSE OR DATING RELATIONSHIP', 'ELDER ADULT OR DEPENDENT ABUSE (NOT EMBEZZLEMENT OR THEFT)', 'THREATENING PHONE CALL(S)')))"
                } else if category == "SEX OFFENSES, FORCIBLE" {
                    categoriesString += "(category = 'SEX OFFENSES, FORCIBLE' AND (descript not in ('CHILD ABUSE, PORNOGRAPHY', 'RAPE, SPOUSAL')))"
                } else { // include all descriptions
                    categoriesString += "(category = '\(category)')"
                }
            }
        }
        
        whereString += "(\(categoriesString))"
        
        // date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.stringFromDate(NSDate())
        let earliestString = dateFormatter.stringFromDate(NSDate().dateBySubtractingMonths(numMonths))
        let dateString = "date between '\(earliestString)' and '\(todayString)'"
        whereString += " AND (\(dateString))"
        
        urlString += whereString
        let percentEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: percentEncoded)
        
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let data = data {
                if let jsonData = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSArray {
                    for crime in jsonData {
                        if let crime = crime as? NSDictionary {
                            let crimeObj = Crime(dict: crime)
                            crimes.append(crimeObj)
                        }
                    }
                }
                print(crimes.count)
                completion(crimes: crimes)
            }
        });
        task.resume()
        
        
        /*let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
         print("completed")
         if let data = dataOrNil {
         print("not nil")
         if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
         print("got things")
         //let stuff = responseDictionary["results"] as? [NSDictionary]
         //print(stuff)
         /*self.movies = responseDictionary["results"] as? [NSDictionary]
         filteredMovies = movies
         self.tableView.reloadData()*/
         }
         }
         })*/
    }
    
    
//    func makeRequest() -> (request: NSURLRequest, session: NSURLSession) {
//        let appToken = ""
//        let url = NSURL(string: "https://data.sfgov.org/resource/cuks-n6tp.json?$$app_token=\(appToken)")
//        let request = NSURLRequest(
//            URL: url!,
//            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
//            timeoutInterval: 10)
//        
//        let session = NSURLSession(
//            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
//            delegate: nil,
//            delegateQueue: NSOperationQueue.mainQueue()
//        )
//        
//        return (request, session)
//    }
    
//    func getData(dataOrNil: NSData?, response: NSURLResponse?, error: NSError?) {
//        //Get new data
//        if let data = dataOrNil {
//            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
//                
//                /*self.movies = responseDictionary["results"] as? [NSDictionary]
//                filteredMovies = movies
//                self.tableView.reloadData()*/
//            }
//        }
//    }
}
