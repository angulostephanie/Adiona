//
//  Constants.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/11/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import Foundation


let pinLength = 6

struct CheckInSettings {
    static let callPoliceDefault = false
    static let messageContactsDefault = true
    static let checkInTimeDefault = 10
}

struct IffyReason {
    var key: String
    var label: String
    var snippet: String
}

let iffies: [IffyReason] = [IffyReason(key: "bad_lighting", label: "Dim or No Lighting", snippet: "bad lighting"),
                            IffyReason(key: "empty", label: "Empty Streets", snippet: "empty streets"),
                            IffyReason(key: "suspicious", label: "Suspicious Activity", snippet: "suspicious activity"),
                            IffyReason(key: "bad_sidewalk", label: "Bad or No Sidewalks", snippet: "bad sidewalks"),
                            IffyReason(key: "noises", label: "Strange Noises", snippet: "strange noises"),
                            IffyReason(key: "police", label: "Police Activity", snippet: "police activity"),
                            IffyReason(key: "wildlife", label: "Wildlife", snippet: "wildlife"),
                            IffyReason(key: "other", label: "Other", snippet: "other")]


let crimeCategories = ["ASSAULT", "ROBBERY", "KIDNAPPING", "SEX OFFENSES, FORCIBLE", "SECONDARY CODES"]

/*
 ----- Parse keys -----
 
 --Under User--
 "email": String
 "name": String
 "fbid": String
 "photo_url": String
 "pin": String
 "check_in_settings": NSDictionary {
    "call_police": Bool
    "message_contacts": Bool
 }
 "identification_info": NSDictionary {
    "name": String
    "age": String
    "gender": String
    "height": String
    "weight": String
    "hair_color": String
    "eye_color": String
    "pictures": [PFFile]
 }
 "selected_contacts": [Contact]
 
 
 --Under Safety_Data--
 "location": NSDictionary {
    "lat": Number
    "long": Number
 }
 "reasons": NSDictionary {
    "bad_lighting": Bool
    "empty": Bool
    "suspicious": Bool
    "bad_sidewalk": Bool
    "noises": Bool
    "police": Bool
    "wildlife": Bool
    "other": String
 }
 */

/*
 Original sorting:
 Don't include:
 arson
 bad checks
 bribery
 driving under the influence
 drug/narcotic
 drunkenness
 embezzlement
 extortion
 family offenses
 forgery/counterfeiting
 fraud
 gambling
 liquor laws
 loitering
 missing person
 non-criminal
 other offenses
 pornography/obscene mat
 prostitution
 recovered vehicle
 runaway
 secondary codes: domestic violence, juvenile involved, [other]
 stolen property
 suicide
 trea (trespassing or loitering near industrial properties)
 trespass
 vandalism
 warrants
 weapon laws

 Include:
 assault
 burglary
 disorderly conduct
 kidnapping
 larceny/theft
 robbery
 secondary codes: gang activity, prejudice-based incident
 sex offenses, forcible
 suspicious occ
 vehicle theft
 
 was changed though--more were not included
 */