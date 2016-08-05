//
//  AddressBookVC.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/22/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import Contacts
import Parse

protocol ContactsHandlerDelegate {
    func retrieveTopThree()
}
class AddressBookVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: ContactsHandlerDelegate? = nil
    var contactDict: [String: String] = [:]
    
    let topThreeSection = 0
    let addressBookSection = 1
    
    var sizeOfEditedAddressBook: Int!
    //var editedAddressBook: [CNContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEW WILL APPEAR")
        if(User._currentUser?.contactsArray.count == 0) {
            User._currentUser?.editedAddressBook = (User._currentUser?.addressBook)!
        }
        
        sizeOfEditedAddressBook = User._currentUser?.editedAddressBook.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == topThreeSection {
            return "Top Three"
        } else {
            return "Address Book"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell
        
        if indexPath.section == topThreeSection {
            
            /* 
             Cells in the top three contact section
             */
            
            if(!User._currentUser!.contactsArray.isEmpty) {
                let contactInfo = User._currentUser!.contactsArray[indexPath.row]
                let fullName = contactInfo.keys.first
                let fullNameArr = fullName!.componentsSeparatedByString(" ")
                let firstName: String = fullNameArr[0]
                var lastName = ""
                
                if fullNameArr.indices.contains(1) {
                    lastName = fullNameArr[1]
                }
                
                cell.firstNameLabel.text = firstName
                cell.lastNameLabel.text = lastName
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                //print("\(firstName) is now in the table view at index path row \(indexPath.row)")
                //self.contactsEdited = true
            }
        } else {
            
            /* 
             Cells in address book section
             */
            let contact = User._currentUser?.editedAddressBook[indexPath.row]
            let firstName = contact!.givenName
            let lastName = contact!.familyName
            
            let fullName = CNContactFormatter.stringFromContact(contact!, style: .FullName)
            cell.firstNameLabel.text = firstName
            cell.lastNameLabel.text = lastName
            
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            if(!User._currentUser!.contactsArray.isEmpty) {
                for i in 0 ..< User._currentUser!.contactsArray.count {
                    if(fullName == User._currentUser!.contactsArray[i].keys.first) {
                        print("\(contact!.givenName) is in top three now!")
                        cell.accessoryType = UITableViewCellAccessoryType.None
                        //REMOVE CONTACT FROM EDITED ARRAY
                    }
                }
            } else {
                User._currentUser?.editedAddressBook = (User._currentUser?.addressBook)!
            }
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == topThreeSection {
            return User._currentUser?.contactsArray.count ?? 0
        } else {
            return sizeOfEditedAddressBook ?? 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            if indexPath.section == addressBookSection {
                /* 
                 If the user selects a cell in the address book section
                 */
                
                let contact = User._currentUser?.editedAddressBook[indexPath.row]
                let fullName = CNContactFormatter.stringFromContact(contact!, style: .FullName)
                let phoneNumbers = contact!.phoneNumbers
                let phoneNumber = (phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as! String
                contactDict = [fullName! : phoneNumber]
                
                tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                if(!(User._currentUser?.contactsArray.isEmpty)!) {
                    /* 
                     If the top three array is not empty
                     Must check to make sure for loop works correctly
                     */
                
                    for i in 0 ..< User._currentUser!.contactsArray.count {
                        if(User._currentUser!.contactsArray[i] == contactDict) {
                            /*
                             If selected cell is already in the top three array, 
                             contact is removed from array
                             */
                            print("Removing \(User._currentUser!.contactsArray[i]) from contact array")
                            User._currentUser!.contactsArray.removeAtIndex(i)
                            
                            for j in 0 ..< User._currentUser!.addressBook.count {
                                if(CNContactFormatter.stringFromContact(User._currentUser!.addressBook[i], style: .FullName) == contactDict.keys.first) {
                                    User._currentUser!.editedAddressBook.insert(contact!, atIndex: i)
                                }
                            }
                            sizeOfEditedAddressBook = User._currentUser?.editedAddressBook.count
                            tableView.reloadData()
                            break
                        } else {
                            if(User._currentUser!.contactsArray.count < 3 ) {
                                /* 
                                 If selected cell is not in the top three array
                                 And array size is less than three, add contact to array
                                 As well as remove contact from edited address book
                                 */
                                print("Adding \(contact!.givenName) to contact array")
                                User._currentUser!.contactsArray.append(contactDict)
                                User._currentUser!.editedAddressBook.removeAtIndex(indexPath.row)
                                sizeOfEditedAddressBook = User._currentUser?.editedAddressBook.count
                                tableView.reloadData()
                                
                            
                            } else {
                                /* 
                                 If top three array is already three,
                                 Restrict user from adding contacts
                                 */
                                print("you can only add 3 contacts to top 3!")
                                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                            }
                            print("Updated contactsArray \(User._currentUser!.contactsArray)")
                        }
                    }
                    
                } else {
                    /* 
                     If top three array was originally empty,
                     Allow user to add to array lol
                     */
                    print("Adding \(contact!.givenName) to contact array")
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    User._currentUser!.contactsArray.append(contactDict)
                    User._currentUser!.editedAddressBook.removeAtIndex(indexPath.row)
                    sizeOfEditedAddressBook = User._currentUser?.editedAddressBook.count
                    tableView.reloadData()
            }
        } else {
            /*
             If the user selects a cell in the top three section -- contact is removed from top three array
            */
            let contactInfo = User._currentUser!.contactsArray[indexPath.row]
            let fullName = contactInfo.keys.first
            let phoneNumber = contactInfo[fullName!]
            contactDict = [fullName! : phoneNumber!]
            print("Selected index path row in top three section -- need to delete this \(fullName) off of top three!")
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
                
            for i in 0 ..< User._currentUser!.contactsArray.count {
                if(User._currentUser!.contactsArray[i] == contactDict) {
                    print("Removing \(User._currentUser!.contactsArray[i]) from contact array")
                    User._currentUser!.contactsArray.removeAtIndex(i)
                    
                    for j in 0 ..< User._currentUser!.addressBook.count {
//                        print(CNContactFormatter.stringFromContact(User._currentUser!.addressBook[j], style: .FullName))
                        let addressBookFullName = CNContactFormatter.stringFromContact(User._currentUser!.addressBook[j], style: .FullName)
                        if(addressBookFullName == fullName) {
                            if(User._currentUser?.editedAddressBook.count <= j) {
                               User._currentUser!.editedAddressBook.append(User._currentUser!.addressBook[j])
                            }
                            else {
                                User._currentUser!.editedAddressBook.insert(User._currentUser!.addressBook[j], atIndex: j)
                            }

                        }
                    }
                    
                    sizeOfEditedAddressBook = User._currentUser?.editedAddressBook.count
                    tableView.reloadData()
                    break
                }
 
            }
            print("AFTER DELETING CONTACT, Updated contactsArray \(User._currentUser!.contactsArray)")

        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    
    @IBAction func didUpdate(sender: AnyObject) {
        if (delegate != nil) {
            print("user has updated top three")
            print("Array updated to \(User._currentUser?.contactsArray)")
            delegate!.retrieveTopThree()
            dismissViewControllerAnimated(true, completion: nil)

        } else {
            print("must add delegate to next view controller")
        }
        
    }
}
