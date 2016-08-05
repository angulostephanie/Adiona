//
//  User.swift
//  safetyApp
//
//  Created by Stephanie Angulo on 7/12/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Contacts
import Parse

class User: NSObject {
    static var _currentUser: User?
    let nameKey = "name"
    let idKey = "id"
    let fbIdKey = "fb_id"
    let emailKey = "email"
    let profileImageKey = "profile_image"
    let pinKey = "pin"
    let birthdayKey = "birthday"
    //var topThreeContacts: [CNContact] = []
    
    var name: String?
    var email: String?
    var id: String?
    var fbid: String?
    var profileImageUrl: String!
    var pin: String!
    var birthday: String?
    var contactsArray: [[String:String]] = []
    var editedAddressBook: [CNContact] = []
    
    lazy var addressBook: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                //print("\(containerResults)")
                results.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    var sizeOfAddressBook: Int {
        get {
            return User._currentUser?.addressBook.count ?? 0
        }
        set {
            self.sizeOfAddressBook = (User._currentUser?.addressBook.count)!
        }
    }

    //setting up user dictionary
    var userDictionary: NSDictionary {
        didSet {
            name = userDictionary[nameKey] as? String
            id = userDictionary[idKey] as? String //id is a string of numbers
            fbid = userDictionary[fbIdKey] as? String // same with fb id
            email = userDictionary[emailKey] as? String
            profileImageUrl = userDictionary[profileImageKey] as? String //url not a string
            pin = userDictionary[pinKey] as? String
            birthday = userDictionary[birthdayKey] as? String //format is MM/DD/YYYY
        }
    }
    
    required init(dictionary: NSDictionary) {
        userDictionary = dictionary
    }
    
}
