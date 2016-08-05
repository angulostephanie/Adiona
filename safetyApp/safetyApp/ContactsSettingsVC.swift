//
//  ContactsSettingsVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/8/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Parse
import Contacts
//protocol ButtonHandlerDelegate {
//    func setUpContactButtons()
//}
class ContactsSettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactsHandlerDelegate {
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var addContactButton: UIButton!

    /*
     First section - the user's top three contacts
     Second section - the add contact button (only exists if there are less than 3 contacts)
     */
    
    var numContacts: Int!
    var contactsEdited = false
    var canAddContacts = true
    var contacts: [CNContact] = []
    
    var addContactIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        print("view DID load")
        
        //print("User's top three contacts: \(User._currentUser?.topThreeContacts)")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("view WILL appear")
        retrieveTopThree()
        print("Var numContacts: \(numContacts)")
    }
    override func viewDidAppear(animated: Bool) {
        print("view did appear")
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Only save data to Parse if the view is disappearing because (1) the back button in the navigation bar was pressed
        if self.isMovingFromParentViewController() || self.parentViewController!.isBeingDismissed() {
            if contactsEdited {
                PFUser.currentUser()!.setObject(User._currentUser!.contactsArray, forKey: "top_three")
                PFUser.currentUser()!.saveInBackground()
                print("VIEW WILL DISAPPEAR - contacts have been edited and save to parse")
                // ***TODO: Save data to Parse
            }
        }
    }
    
    func retrieveTopThree() {
        /* Sets local array of contacts to the top three contacts array
        TODO -- pull in array from parse and then set it to top three contacts
        before setting local array
         */
        if(!User._currentUser!.contactsArray.isEmpty) {
            numContacts = User._currentUser!.contactsArray.count
            print("Num Contacts \(numContacts)")
        } else {
            numContacts = 0
        }
        
        if User._currentUser!.contactsArray.count == 3 {
            print("User interaction with add contact is false")
            addContactButton.userInteractionEnabled = false
            addContactButton.titleLabel?.textColor = addContactButton.tintColor
        } else {
            print("User interaction with add contact is true")
            addContactButton.userInteractionEnabled = true
            addContactButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        contactsTableView.reloadData()
        print(" RETRIEVING TOP THREE - User's top three contacts: \(User._currentUser?.contactsArray)")
    }
    
//    func loadFromParse() {
//        /* 
//         Loads previously saved top three contacts from Parse
//         
//         */
//        let query = PFQuery(className:"User")
//        query.includeKey("top_three")
//        
//        query.findObjectsInBackgroundWithBlock { (topThreeContacts: [PFObject]?, error:NSError?) in
//            if error != nil {
//                print(error)
//            } else {
//                print("Successfully retrieved \(topThreeContacts!.count) contacts from Parse. - load from parse func")
//                User._currentUser?.topThreeContacts = topThreeContacts as! [CNContact]
//                self.contactsTableView.reloadData()
//            }
//        }
//    }
//    
//    func addToParse() {
//        
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectedContactCell", forIndexPath: indexPath) as! SelectedContactCell

        if(!User._currentUser!.contactsArray.isEmpty) {
            let contactInfo = User._currentUser!.contactsArray[indexPath.row]
            let fullName = contactInfo.keys.first
            let fullNameArr = fullName!.componentsSeparatedByString(" ")
            let firstName: String = fullNameArr[0]
            var lastName = ""
            if fullNameArr.indices.contains(1) {
                lastName = fullNameArr[1]
            }
            print("\(firstName) is now in the table view at index path row \(indexPath.row)")
            cell.firstNameLabel.text = firstName
            cell.lastNameLabel.text = lastName
            self.contactsEdited = true
        }
        
        
        cell.removeHandler = { (cell: SelectedContactCell) -> () in
            let indexPathh = tableView.indexPathForCell(cell)
            print("remove handler index path \(indexPathh)")
            if indexPathh == nil {
                return
            }
            
            self.contactsEdited = true

            tableView.beginUpdates()
            User._currentUser!.contactsArray.removeAtIndex(indexPathh!.row)
            self.retrieveTopThree()
            print("Updated array: \(User._currentUser?.contactsArray)")
            tableView.deleteRowsAtIndexPaths([indexPathh!], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numContacts ?? 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func onAddContactButton(sender: AnyObject) {
        print("clicked on add contact button")
        if(addContactButton.userInteractionEnabled == true) {
            self.performSegueWithIdentifier("addressBookSegue", sender: nil)
        } else {
            print("User cannot access address book, they must delete contacts")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addressBookSegue" {
            let addressBookVC: AddressBookVC = segue.destinationViewController as! AddressBookVC
            addressBookVC.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
