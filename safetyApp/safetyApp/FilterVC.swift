//
//  FilterVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/29/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit

class FilterVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var crimeTableView: UITableView!
    @IBOutlet weak var iffyTableView: UITableView!
    
    var mainVC: MainViewController?
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var chosenCrimes = [String: Bool]()
    var chosenIffies = [String: Bool]()
    
    let iffyCategoriesCount = iffies.count - 1 // exclude "other"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crimeTableView.delegate = self
        iffyTableView.delegate = self
        crimeTableView.dataSource = self
        iffyTableView.dataSource = self
        
        if let crimes = defaults.dictionaryForKey("chosenCrimeCategories") as? [String: Bool] {
            chosenCrimes = crimes
        } else {
            for cat in crimeCategories {
                chosenCrimes[cat] = true
            }
        }
        
        if let iffies = defaults.dictionaryForKey("chosenIffyCategories") as? [String: Bool] {
            chosenIffies = iffies
        } else {
            for i in 0..<iffyCategoriesCount {
                chosenIffies[iffies[i].key] = true
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == crimeTableView {
            return crimeCategories.count
        } else if tableView == iffyTableView {
            return iffyCategoriesCount
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == crimeTableView {
            let cell = crimeTableView.dequeueReusableCellWithIdentifier("crimeCell") as! CrimeCategoryCell

            let category = crimeCategories[indexPath.row]
            cell.category = category.capitalizedString
            if let value = chosenCrimes[category] where value {
                cell.accessoryType = .Checkmark
            }

            
            return cell
        } else if tableView == iffyTableView {
            let cell = iffyTableView.dequeueReusableCellWithIdentifier("iffyCell") as! IffyCategoryCell

            cell.category = iffies[indexPath.row].label
            if let value = chosenIffies[iffies[indexPath.row].key] where value {
                cell.accessoryType = .Checkmark
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {
            cell?.accessoryType = .None
            
            if tableView == crimeTableView {
                chosenCrimes[crimeCategories[indexPath.row]] = false
            } else if tableView == iffyTableView {
                chosenIffies[iffies[indexPath.row].key] = false
            }
        } else {
            cell?.accessoryType = .Checkmark
            
            if tableView == crimeTableView {
                chosenCrimes[crimeCategories[indexPath.row]] = true
            } else if tableView == iffyTableView {
                chosenIffies[iffies[indexPath.row].key] = true
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // check for editing
        // if edited: set defaults, call load data
        if wasEdited() {
            defaults.setObject(chosenCrimes, forKey: "chosenCrimeCategories")
            defaults.setObject(chosenIffies, forKey: "chosenIffyCategories")
            defaults.synchronize()
            
            mainVC?.loadSafetyData()
        }
    }
    
    func wasEdited() -> Bool {
        guard let savedCrimes = defaults.dictionaryForKey("chosenCrimeCategories") as? [String: Bool],
            let savedIffies = defaults.dictionaryForKey("chosenIffyCategories") as? [String: Bool] else {
                return true
        }
        
        if NSDictionary(dictionary: savedCrimes).isEqualToDictionary(chosenCrimes)
            && NSDictionary(dictionary: savedIffies).isEqualToDictionary(chosenIffies) {
            return false
        } else {
            return true
        }
    }

}
