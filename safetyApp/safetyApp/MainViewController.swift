//
//  MainViewController.swift
//  safetyApp
//
//  Created by Angela Chen on 7/7/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AVFoundation
import MediaPlayer
import Parse
import SideMenu
import Contacts
import SwiftRequest
import QuartzCore
import FBSDKCoreKit
import ParseFacebookUtilsV4


class MainViewController: UIViewController, CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate, ButtonHandlerDelegate, ContactsHandlerDelegate, PopupDelegate, DimDelegate {
    
    /*********** OUTLETS ***********/
    
    @IBOutlet weak var addContactsButton: UIButton!
    @IBOutlet weak var startSafeButton: UIButton!
    @IBOutlet weak var noiseButton: UIButton!
    @IBOutlet weak var emergencyButton: UIButton!
    @IBOutlet weak var iffyButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var videoView: UIButton!
    
    @IBOutlet weak var loadingSafetyLabel: UILabel!
    
    @IBOutlet weak var BUTTON_HEIGHT: NSLayoutConstraint!
    @IBOutlet weak var SMALL_BUTTON_HEIGHT: NSLayoutConstraint!
    @IBOutlet weak var CONTACT_WIDTH: NSLayoutConstraint!
    @IBOutlet weak var BOTTOM_START_SAFE_BUTTON: NSLayoutConstraint!
    
    @IBOutlet weak var videoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoViewWidth: NSLayoutConstraint!
    @IBOutlet weak var videoViewFrameTop: NSLayoutConstraint!
    @IBOutlet weak var videoViewFrameLeft: NSLayoutConstraint!
    @IBOutlet weak var xMark: UIButton!
    
    @IBOutlet weak var firstContactButton: UIButton!
    @IBOutlet weak var secondContactButton: UIButton!
    @IBOutlet weak var thirdContactButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var infoWindowView: UIView!
    
    /*********** GLOBALS ***********/
    
    var NAVIGATION_HEIGHT: CGFloat!
    var VIDEO_RADIUS: CGFloat!
    
    // Search bar
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var cancelButton: UIBarButtonItem!
    
    // Location/Map infromation
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D!
    
    var route: GMSPolyline!
    var DEFAULT_ZOOM: Float = 17
    
    var startingLocation: CLLocationCoordinate2D!
    var startingPlaceName: String!
    var startingPlaceAddress: String!
    
    var destinationLocation: CLLocationCoordinate2D!
    var destinationName: String!
    var destinationAddress: String!
    
    var placesClient: GMSPlacesClient!
    var path:GMSMutablePath!
    
    var startingMarker:GMSMarker!
    var endingMarker:GMSMarker!
    
    var pinchedOrPanned: Bool = false
    
    // Start/Safe Buttons
    var started: Bool = false
    var safe: Bool = false
    var hasDestination: Bool?
    
    // Video Recording Items
    var recOn: Bool = false
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let captureSession = AVCaptureSession()
    var captureOutput = AVCaptureMovieFileOutput()
    var captureDevice: AVCaptureDevice?
    var audioDevice: AVCaptureDevice?
    var outputPath = "\(NSTemporaryDirectory())/safetyapp.mov"
    var originalCenter: CGPoint!
    
    var origVidViewSize: CGFloat!
    var origVidViewTop: CGFloat!
    var origVidViewLeft: CGFloat!
    
    // Audio Player
    var audioPlayer:AVAudioPlayer!
    var currentVolume: Float = 0
    var prepped: Bool = false
    
    // Safety Data
    let dataSnippetText = NSMutableDictionary()
    var clusterManager: GMUClusterManager!
    let IFFY_IMAGE = UIImage(named: "User")
    let CRIME_IMAGE = UIImage(named: "Handcuffs")
    
    //Contacts
    var currentTopThree: [[String: String]] = []
    var numContacts: Int!
    
    // Twilio
    let twilioAccountSID = "ACcdfffb6da68b6716f77f68baef989cdb"
    let twilioAuthToken = "3bab1ac80c3ccc8c206d487a614d727f"

    
    // Timer
    var timer: NSTimer!
    var checkInSettings: NSMutableDictionary!
    var CHECKIN_TIME: Double!
    
    /*********** STARTING INFORMATION ***********/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstContactButton.hidden = true
        secondContactButton.hidden = true
        thirdContactButton.hidden = true
        
        loadingSafetyLabel.hidden = true
        
        let settingsFromParse = PFUser.currentUser()!.objectForKey("check_in_settings") as? NSMutableDictionary
        
        if let settings = settingsFromParse {
            checkInSettings = settings
        }
        
        refreshCheckin()

        setupSideMenu()
        setupSearch()
        setupVideo()
        setupAudioPlayer()
        
        // Setup map requirements
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyNearestTenMeters
            //manager.distanceFilter = 10
            locationManager.startUpdatingLocation()
            mapView.settings.consumesGesturesInView = false
            mapView.myLocationEnabled = true
            
            if let location = locationManager.location {
                mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: DEFAULT_ZOOM)
            }
        }
        
        mapView.delegate = self
        audioPlayer.delegate = self
        dimRecord()
        
        placesClient = GMSPlacesClient.sharedClient()
        path = GMSMutablePath()

        // Setup safety data information
        for iffy in iffies {
            dataSnippetText[iffy.key] = iffy.snippet
        }
        
        setupClusterManager()

        loadSafetyData()

    }
    
    
    /*func makeSFIffies() {
        for _ in 0..<20 {
            
            // randomize location
            var location = CLLocationCoordinate2D(latitude: 37.724768, longitude: -122.468805)
            
            srand48(Int(arc4random()))
            let latShift = (drand48() - 0.5) * 2 * 0.02
            location.latitude += latShift
            let longShift = (drand48() - 0.5) * 2 * 0.02
            location.longitude += longShift
            
            // randomize reasons
            var reasons: [String] = []
            let firstReason = iffies[Int(drand48() * Double((iffies.count - 1)))].key
            reasons.append(firstReason)
            
            for i in 0..<(iffies.count - 1) {
                if drand48() < 0.2 {
                    reasons.append(iffies[i].key)
                }
            }
            
            let data = Iffy(location: location, reasons: reasons)
            data.postToParse { (success: Bool, error: NSError?) in
                if success {
                    print("posted!")
                    
                    // add created marker to map
                    self.clusterManager.addItem(data)
                } else {
                    print(error?.localizedDescription)
                }
            }
        }
     
    }*/
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpContactButtons()
        print("View Did Appear?")
    }
    override func viewDidLayoutSubviews() {
        setupButton(noiseButton)
        setupButton(emergencyButton)
        setupButton(iffyButton)
    }
    
    func dimRecord() {
        recButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        recButton.layer.borderWidth = 1
        recButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*********** SIDE MENU ***********/
    
    func setupSideMenu() {
        let menuLeftNavC = UISideMenuNavigationController()
        menuLeftNavC.leftSide = true
        SideMenuManager.menuLeftNavigationController = menuLeftNavC
        
        let menuRightNavC = UISideMenuNavigationController()
        SideMenuManager.menuRightNavigationController = menuRightNavC
        
        SideMenuManager.menuWidth = UIScreen.mainScreen().bounds.width / 1.5
    }
    
    @IBAction func menuButton(sender: AnyObject) {
        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func filterButton(sender: AnyObject) {
        presentViewController(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
    }
    /*********** IMPORTANT DATA LOADING ***********/
    
    func refreshCheckin() {
        //if let minutes = checkInSettings["check_time"] as? String {
          //  CHECKIN_TIME = Double(minutes)! * 60
        //} else {
            CHECKIN_TIME = Double(CheckInSettings.checkInTimeDefault) //* 60
       // }
        
        print("CHECK-IN TIME: \(CHECKIN_TIME)")
    }
    
    func setupSearch() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchController?.searchBar.delegate = self
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func setupVideo() {
        setupCamera()
        
        // Add gesture recognizers to VideoView
        let videoGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.videoPanned(_:)))
        videoGestureRecognizer.delegate = self
        videoView.addGestureRecognizer(videoGestureRecognizer)
        
        let videoExpandGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.videoExpanded(_:)))
        videoView.addGestureRecognizer(videoExpandGestureRecognizer)
        
        // Design Elements
        VIDEO_RADIUS = videoView.frame.width/2
        NAVIGATION_HEIGHT = navigationController!.navigationBar.frame.size.height
        
        videoView.layer.cornerRadius = VIDEO_RADIUS
        videoView.layer.masksToBounds = true
        
        originalCenter = videoView.center
        origVidViewSize = videoViewHeight.constant
        origVidViewTop = videoViewFrameTop.constant
        origVidViewLeft = videoViewFrameLeft.constant
        
        // Hidden Views
        xMark.hidden = true
        videoView.hidden = true
        
        let noiseGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.noiseTapped(_:)))
        //noiseGestureRecognizer.delegate = self
        noiseButton.addGestureRecognizer(noiseGestureRecognizer)
    }
    
    func setupAudio() {
        if !prepped {
            prepped = true
            audioPlayer.prepareToPlay()
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func setupAudioPlayer() {
        self.view.addSubview(MPVolumeView(frame: CGRectZero))
        
        if let soundURL = NSBundle.mainBundle().URLForResource("airhorn", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: soundURL)
            } catch {
                print("setup audio player error")
            }
        }
    }
    
    func designButtons(button: UIButton) {
        button.layer.shadowRadius = 3.0
        button.layer.shadowColor = UIColor.blackColor().CGColor
        button.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        button.layer.shadowOpacity = 0.5
        button.layer.masksToBounds = false
    }
    func unclickedLocationButton(button: UIButton) {
        button.setImage(UIImage(named: "currentLocation.png"), forState: UIControlState.Normal)
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).CGColor
    }
    func clickedLocationButton(button: UIButton) {
        button.setImage(UIImage(named: "graycurrentLocation.png"), forState: UIControlState.Normal)
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor.blackColor()
        button.layer.borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0).CGColor
    }

    func setUpContactButtons() {
        unclickedLocationButton(locationButton)
        designButtons(addContactsButton)
        designButtons(firstContactButton)
        designButtons(secondContactButton)
        designButtons(thirdContactButton)
        
        print("MAIN SCREEN - Contact Array: \(User._currentUser?.contactsArray)")
        currentTopThree = (User._currentUser?.contactsArray)! //updating model class
        
        var fullNameArr: [String] = []
        var firstName = ""
        var lastName = ""
        var firstInitial = ""
        var secondInitial = ""

        if((currentTopThree.isEmpty) == false) {
            print("top three contact list is NOT empty ")
            if((currentTopThree.indices.contains(2)) == true) {
                thirdContactButton.hidden = false
                secondContactButton.hidden = false
                firstContactButton.hidden = false
                
                fullNameArr = currentTopThree[2].keys.first!.componentsSeparatedByString(" ")
                firstName = fullNameArr[0]
                firstInitial = String(firstName[firstName.startIndex.advancedBy(0)])
                if fullNameArr.indices.contains(1) {
                    lastName = fullNameArr[1]
                    secondInitial = String(lastName[lastName.startIndex.advancedBy(0)])
                    thirdContactButton.setTitle("\(firstInitial + secondInitial)", forState: .Normal)
                } else {
                    thirdContactButton.setTitle("\(firstInitial)", forState: .Normal)
                }
                
                fullNameArr = currentTopThree[1].keys.first!.componentsSeparatedByString(" ")
                firstName = fullNameArr[0]
                firstInitial = String(firstName[firstName.startIndex.advancedBy(0)])
                if fullNameArr.indices.contains(1) {
                    lastName = fullNameArr[1]
                    secondInitial = String(lastName[lastName.startIndex.advancedBy(0)])
                    secondContactButton.setTitle("\(firstInitial + secondInitial)", forState: .Normal)
                } else {
                    
                    secondContactButton.setTitle("\(firstInitial)", forState: .Normal)
                }
                
                fullNameArr = currentTopThree[0].keys.first!.componentsSeparatedByString(" ")
                firstName = fullNameArr[0]
                firstInitial = String(firstName[firstName.startIndex.advancedBy(0)])
                if fullNameArr.indices.contains(1) {
                    lastName = fullNameArr[1]
                    secondInitial = String(lastName[lastName.startIndex.advancedBy(0)])
                    firstContactButton.setTitle("\(firstInitial + secondInitial)", forState: .Normal)
                } else {
                    firstContactButton.setTitle("\(firstInitial)", forState: .Normal)
                }
                print("HAS THREE CONTACTS - reload func")
            } else if((currentTopThree.indices.contains(1)) == true) {
                thirdContactButton.hidden = true
                secondContactButton.hidden = false
                firstContactButton.hidden = false
                
                fullNameArr = currentTopThree[1].keys.first!.componentsSeparatedByString(" ")
                firstName = fullNameArr[0]
                firstInitial = String(firstName[firstName.startIndex.advancedBy(0)])
                if fullNameArr.indices.contains(1) {
                    lastName = fullNameArr[1]
                    secondInitial = String(lastName[lastName.startIndex.advancedBy(0)])
                    secondContactButton.setTitle("\(firstInitial + secondInitial)", forState: .Normal)
                } else {
                    secondContactButton.setTitle("\(firstInitial)", forState: .Normal)
                }
                
                
                fullNameArr = currentTopThree[0].keys.first!.componentsSeparatedByString(" ")
                firstName = fullNameArr[0]
                firstInitial = String(firstName[firstName.startIndex.advancedBy(0)])
                if fullNameArr.indices.contains(1) {
                    lastName = fullNameArr[1]
                    secondInitial = String(lastName[lastName.startIndex.advancedBy(0)])
                    firstContactButton.setTitle("\(firstInitial + secondInitial)", forState: .Normal)
                } else {
                    firstContactButton.setTitle("\(firstInitial)", forState: .Normal)
                }
                
                print("HAS TWO CONTACTS - reload func")
            } else if((currentTopThree.indices.contains(0)) == true) {
                thirdContactButton.hidden = true
                secondContactButton.hidden = true
                firstContactButton.hidden = false
                
                fullNameArr = currentTopThree[0].keys.first!.componentsSeparatedByString(" ")
                firstName = fullNameArr[0]
                firstInitial = String(firstName[firstName.startIndex.advancedBy(0)])
                if fullNameArr.indices.contains(1) {
                    lastName = fullNameArr[1]
                    secondInitial = String(lastName[lastName.startIndex.advancedBy(0)])
                    firstContactButton.setTitle("\(firstInitial + secondInitial)", forState: .Normal)
                } else {
                    
                    firstContactButton.setTitle("\(firstInitial)", forState: .Normal)
                }
                
                print("HAS ONLY ONE CONTACT")
            }
        } else {
            thirdContactButton.hidden = true
            secondContactButton.hidden = true
            firstContactButton.hidden = true
            print("Top three contacts' array is empty --- all buttons are hidden")
        }
    }
    
    /*********** SAFETY DATA ***********/
    
    func loadSafetyData() {
        var iffiesFinished = false
        var crimesFinished = false
        loadingSafetyLabel.hidden = false
        
        // hides the loading text when getting both iffy and crime data
        // has been fully completed
        // also clusters
        func doneLoading() {
            if iffiesFinished && crimesFinished {
                self.clusterManager.cluster()
                loadingSafetyLabel.hidden = true
            }
        }
        
        // get filtered categories
        let defaults = NSUserDefaults.standardUserDefaults()
        var filteredCrimeCategories = [String: Bool]()
        if let crimeCats = defaults.dictionaryForKey("chosenCrimeCategories") as? [String: Bool] {
            filteredCrimeCategories = crimeCats
        } else {
            for cat in crimeCategories {
                filteredCrimeCategories[cat] = true
            }
        }
        
        Iffy._filteredCategories = defaults.dictionaryForKey("chosenIffyCategories") as? [String: Bool]
        // clear current clusters
        clusterManager.clearItems()
        
        // get user data
        let query = PFQuery(className: "Safety_Data")
        // default is 100. Since #data < 100 right now, not a problem. Max limit is 1000.
        query.findObjectsInBackgroundWithBlock { (data: [PFObject]?, error: NSError?) in
            if let data = data {
                for i in 0..<data.count {
                    let dataObj = Iffy(object: data[i])
                    if !dataObj.filteredOut {
                        self.clusterManager.addItem(dataObj)
                    }
                }
            }
            
            iffiesFinished = true
            doneLoading()
        }
        
        // get crime data
        CrimeClient.getData(filteredCrimeCategories, completion: { (crimes: [Crime]) -> () in
            for crime in crimes {
                self.clusterManager.addItem(crime)
            }
            
            crimesFinished = true
            doneLoading()
        })
    }
    
    func setupClusterManager() {
        
        let iconGenerator = CustomClusterIconGenerator(buckets: [10, 50, 100, 200, 1000], hexColors: [0x188ffb, 0xfdbe2c, 0xfc0d1b, 0xff28f0, 0xb627ff]) //colors: blue, yellow, red, pink, purple

        let algorithm = CustomNonHierarchicalDistanceBasedAlgorithm()
        algorithm.kGMUClusterDistancePoints = 75
        let renderer = CustomClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        renderer.kGMUMinClusterSize = 1
        renderer.kGMUMaxClusterZoom = 21 // markers on top of each other stay a cluster at any zoom level
        
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
    }
    
    func makeClusterInfoWindow(marker: GMSMarker!) -> UIView? {
        // get nib with info windows and cluster data
        guard let cluster = marker.userData as? GMUCluster else {
            return nil
        }
        
        if cluster.count == 1 { // single item cluster
            let item = cluster.items[0]
            return makeSingleMarkerIW(item)
        } else if cluster.count == 2 { // double item cluster
            guard let nib = NSBundle.mainBundle().loadNibNamed("MarkerInfoWindows", owner: self, options: nil) as? [UIView] else {
                return nil
            }
            
            let foundIndex = nib.indexOf { (view: UIView) -> Bool in
                if view.restorationIdentifier == "doubleMarkerIW" {
                    return true
                } else {
                    return false
                }
            }
            
            guard let index = foundIndex, let infoWindow = nib[index] as? DoubleMarkerIW else {
                return nil
            }
            
            if let leftIW = makeSingleMarkerIW(cluster.items[0]),
                let rightIW = makeSingleMarkerIW(cluster.items[1]) {
                infoWindow.addViews(leftIW, right: rightIW)
            } else {
                return nil
            }

            return infoWindow
        } else { // large item cluster
            // sort cluster into crimes and iffies
            var crimeItems: [GMUClusterItem] = []
            var iffyItems: [GMUClusterItem] = []
            for item in cluster.items {
                if item.type == "iffy" {
                    iffyItems.append(item)
                } else if item.type == "crime" {
                    crimeItems.append(item)
                }
            }
            
            if crimeItems.count > 0 {
                if iffyItems.count > 0 { // both
                    // get double-list info window
                    guard let nib = NSBundle.mainBundle().loadNibNamed("MarkerInfoWindows", owner: self, options: nil) as? [UIView] else {
                        return nil
                    }
                    
                    let foundIndex = nib.indexOf { (view: UIView) -> Bool in
                        if view.restorationIdentifier == "doubleListIW" {
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    guard let index = foundIndex, let infoWindow = nib[index] as? DoubleListIW else {
                        return nil
                    }
                    
                    // add single-lists to the double-list window
                    guard let crimeIW = makeSingleListIW(crimeItems, type: "crime"),
                        let iffyIW = makeSingleListIW(iffyItems, type: "iffy") else {
                            return nil
                    }
                    
                    // the one with more items goes on top
                    if iffyItems.count >= crimeItems.count {
                        infoWindow.addViews(iffyIW, bottom: crimeIW)
                    } else {
                        infoWindow.addViews(crimeIW, bottom: iffyIW)
                    }
                    
                    return infoWindow
                } else { // only crimes
                    return makeSingleListIW(crimeItems, type: "crime")
                }
            } else {
                if iffyItems.count > 0 { // only iffies
                    return makeSingleListIW(iffyItems, type: "iffy")
                } else { // neither
                    return nil
                }
            }
        }
    }
    
    func makeSingleListIW(items: [GMUClusterItem], type: String) -> UIView? {
        guard let nib = NSBundle.mainBundle().loadNibNamed("MarkerInfoWindows", owner: self, options: nil) as? [UIView] else {
            return nil
        }
        
        // get appropriate info window view
        let foundIndex = nib.indexOf { (view: UIView) -> Bool in
            if view.restorationIdentifier == "singleListIW" {
                return true
            } else {
                return false
            }
        }
        
        guard let index = foundIndex, let infoWindow = nib[index] as? SingleListIW else {
            return nil
        }
        
        // make count of all reasons
        if type == "crime" {
            guard let crimes = items as? [Crime] else {
                return nil
            }
            
            var crimesCount = [String: Int]()
            for crime in crimes {
                let key = crime.descript //"\(crime.category): \(crime.descript)"
                if crimesCount[key] != nil {
                    crimesCount[key] = (crimesCount[key]!) + 1
                } else {
                    crimesCount[key] = 1
                }
            }
            
            // populate info window with data
            infoWindow.titleLabel.text = "Top crimes"
            infoWindow.backgroundImageView.image = CRIME_IMAGE
            infoWindow.countLabel.text = "\(items.count)"
            
            guard let topReasons = determineTopThree(crimesCount) else {
                return infoWindow
            }
            
            var crimesString = ""
            for crime in topReasons {
                if crimesString != "" {
                    crimesString += "\n"
                }
                crimesString += "- \(crime.lowercaseString)"
            }
            
            infoWindow.descriptionLabel.text = crimesString
        } else if type == "iffy" {
            guard let iffies = items as? [Iffy] else {
                return nil
            }
            
            var reasonsCount = [String: Int]()
            for iffy in iffies {
                
                for (reason, value) in iffy.filteredReasons {
                    guard let reason = reason as? String where reason != "other" else {
                        continue
                    }
                    
                    guard let value = value as? Bool else {
                        continue
                    }
                    
                    if value {
                        if reasonsCount[reason] != nil {
                            reasonsCount[reason] = (reasonsCount[reason]!) + 1
                        } else {
                            reasonsCount[reason] = 1
                        }
                    }
                }
            }
            
            // populate info window with data
            infoWindow.titleLabel.text = "Top user reasons"
            infoWindow.backgroundImageView.image = IFFY_IMAGE
            infoWindow.countLabel.text = "\(items.count)"
            
            guard let topReasons = determineTopThree(reasonsCount) else {
                return infoWindow
            }
            
            var reasonsString = ""
            for reason in topReasons {
                if let str = dataSnippetText[reason], let num = reasonsCount[reason] {
                    if reasonsString != "" {
                        reasonsString += "\n"
                    }
                    reasonsString += "- \(str): \(num)"
                }
            }
            
            infoWindow.descriptionLabel.text = reasonsString

        }
        
        return infoWindow
    }
    
    func determineTopThree(dict: [String: Int]) -> [String]? {
        // determine top three reaons
        let keys = [String](dict.keys)
        if keys.count == 0 {
            // ***TODO
            return nil
        }
        
        var first = keys[0]
        var secondOrNil: String?
        var thirdOrNil: String?
        var overflow: [String] = [] // used for ties that cause there to be >3 top errors
        
        // Check for overflow. Should only be called when shifting things down and there's a tie with current third.
        func checkOverflow() {
            guard let third = thirdOrNil else {
                overflow.removeAll()
                return
            }
            
            if overflow.count > 0 {
                overflow.append(third)
            } else {
                overflow = [third]
            }
        }
        
        for i in 1..<keys.count {
            let key = keys[i]
            // key's value is the highest so far (or tied with first)
            if dict[key] >= dict[first] {
                if let second = secondOrNil {
                    if let third = thirdOrNil where dict[second] == dict[third] {
                        checkOverflow()
                    } else {
                        overflow.removeAll()
                    }
                    thirdOrNil = second
                }
                secondOrNil = first
                first = key
                continue
            }
            
            // a second reason has not been set
            guard let second = secondOrNil else {
                secondOrNil = key
                continue
            }
            
            // second exists already, and key's value is second highest so far (or tied with second)
            if dict[key] >= dict[second] {
                if let third = thirdOrNil where dict[second] == dict[third] {
                    checkOverflow()
                } else {
                    overflow.removeAll()
                }
                thirdOrNil = second
                secondOrNil = key
                continue
            }
            
            // a third reason has not been set
            guard let third = thirdOrNil else {
                thirdOrNil = key
                continue
            }
            
            // third exists already, and key's value is third highest so far
            if dict[key] > dict[third] {
                thirdOrNil = key
                overflow.removeAll()
                continue
            }
            
            // third exists already, and key's value is tied with third
            if dict[key] == dict[third] {
                checkOverflow()
                thirdOrNil = key
            }
        }
        
        // if there are more than 2 tied for third, remove them all
        if let second = secondOrNil, let third = thirdOrNil
            where overflow.count > 1 && dict[second] != dict[third] {
            thirdOrNil = nil
            overflow.removeAll()
        }
        
        // create array of top reasons
        var topReasons: [String] = [first]
        if let second = secondOrNil {
            topReasons.append(second)
        }
        if let third = thirdOrNil {
            topReasons.append(third)
        }
        for string in overflow {
            topReasons.append(string)
        }
        
        return topReasons
    }
    
    func makeSingleMarkerIW(item: GMUClusterItem) -> UIView? {
        guard let nib = NSBundle.mainBundle().loadNibNamed("MarkerInfoWindows", owner: self, options: nil) as? [UIView] else {
            return nil
        }
        
        // get appropriate info window view
        let foundIndex = nib.indexOf { (view: UIView) -> Bool in
            if view.restorationIdentifier == "singleMarkerIW" {
                return true
            } else {
                return false
            }
        }
        
        guard let index = foundIndex, let infoWindow = nib[index] as? SingleMarkerIW else {
            return nil
        }
        
        // populate info window with data
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy h:mm a"
        
        // of type "iffy"
        if item.type == "iffy" {
            guard let item = item as? Iffy else {
                return nil
            }
            
            infoWindow.backgroundImageView.image = IFFY_IMAGE
            
            if let date = item.time {
                infoWindow.timestampLabel.text = dateFormatter.stringFromDate(date)
            }
            
            var reasonsString = ""
            
            // Create list of reasons: loop through all possible reasons. If not "other", determine if value is true or false.
            // If true, add that reason to the string.
            for (reason, value) in item.filteredReasons {
                guard let reason = reason as? String where reason != "other" else {
                    continue
                }
                
                guard let str = dataSnippetText[reason] as? String,
                    let value = value as? Bool where value else {
                        continue
                }
                
                if reasonsString != "" {
                    reasonsString += ", "
                }
                reasonsString += str
            }
            
            infoWindow.titleLabel.text = ""
            infoWindow.descriptionLabel.text = reasonsString
            print(reasonsString)
        } else if item.type == "crime" {
            guard let item = item as? Crime else {
                return nil
            }
            
            infoWindow.backgroundImageView.image = CRIME_IMAGE
            
            let category = item.category.capitalizedString
            let descript = item.descript.lowercaseString
            infoWindow.titleLabel.text = category
            infoWindow.descriptionLabel.text = descript
            if let date = item.time {
                infoWindow.timestampLabel.text = dateFormatter.stringFromDate(date)
            }
        }
        
        return infoWindow
    }
    
    /*func makeSafetyMarker(data: Iffy) {
        let marker = GMSMarker()
        marker.position = data.locationAsCoord
        marker.map = self.mapView
        marker.icon = self.SAFETY_DATA_MARKER
     
        var reasonsString = ""
     
        // create list of reasons
        for (reason, value) in data.reasons {
            let reason = reason as! String
            
            if reason == "other" {
                continue
            }
            
            let value = value as! Bool
            if value {
                // get snippet text and add to string
                if let str = dataSnippetText[reason] as? String {
                    if reasonsString != "" {
                        reasonsString += ", "
                    }
                    reasonsString += str
                }
            }
        }
        
        marker.snippet = reasonsString
    }
    
    func makeCrimeMarker(data: Crime) {
        let marker = GMSMarker()
        marker.position = data.location
        marker.map = self.mapView
        marker.icon = self.CRIME_DATA_MARKER
        
        marker.title = data.category
        marker.snippet = data.descript
    }*/
    

    /*********** BUTTON SETUP ***********/
    func setupButton(button: UIButton) {
        let spacing: CGFloat = 8.0
        let imageSize: CGSize = button.imageView!.image!.size
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, -(imageSize.height + spacing), 0.0)
        let labelString = NSString(string: button.titleLabel!.text!)
        let titleSize = labelString.sizeWithAttributes([NSFontAttributeName: button.titleLabel!.font])
        button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -titleSize.width)
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        button.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0)
        
        button.titleLabel?.attributedText = letterSpacing(button.currentTitle!, spacing: 0.4)
    }
    
    /*********** NOISE/IFFY BUTTON ***********/
    
    func noiseTapped(sender: UITapGestureRecognizer) {
        setupAudio()
        
        if !audioPlayer.playing {
            currentVolume = AVAudioSession.sharedInstance().outputVolume
            print(currentVolume)
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(1, animated: false)
            audioPlayer.volume = 1.0
            audioPlayer.play()
            audioPlayer.numberOfLoops = 0
            noiseButton.setImage(UIImage(named: "sirenon"), forState: .Normal)
            
            print("tap playing")
            
        } else {
            offNoiseButton(self)
            noiseButton.setImage(UIImage(named: "siren"), forState: .Normal)
            
            print("tap to stop")
        }
    }
    
    @IBAction func noiseHold(sender: AnyObject) {
        setupAudio()
        
        if !audioPlayer.playing {
            currentVolume = AVAudioSession.sharedInstance().outputVolume
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(1, animated: false)
            audioPlayer.play()

            audioPlayer.numberOfLoops = -1
            noiseButton.setImage(UIImage(named: "sirenon"), forState: .Normal)
        }
    }
    
    @IBAction func noiseDragOut(sender: AnyObject) {
        offNoiseButton(sender)
    }
    
    @IBAction func offNoiseButton(sender: AnyObject) {
        audioPlayer.stop()
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(currentVolume, animated: false)
        audioPlayer.currentTime = 0
        noiseButton.setImage(UIImage(named: "siren"), forState: .Normal)
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions: AVAudioSessionSetActiveOptions.NotifyOthersOnDeactivation)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        offNoiseButton(self)
        
        print("audio player finished playing")
    }
    
    /*********** EMERGENCY BUTTON ***********/
    @IBAction func onEmergencyButtonPressed(sender: AnyObject) {
        if let url = NSURL(string: "tel://\(707931888)\(6)") {
            UIApplication.sharedApplication().openURL(url)
        }
        
        if (!(User._currentUser?.contactsArray.isEmpty)!) {
            let clatitude = String(currentLocation.latitude)
            let clongitude = String(currentLocation.longitude)
            let currentLocationLink = "https://www.google.com/maps/preview/@\(clatitude),\(clongitude),16z"
            
            let emergencyMessage = " has called the police. Go check on them."
            let currentLocationMessage = "'s current location \(currentLocationLink)."
            sendAutomatedTextMessages(emergencyMessage)
            sendAutomatedTextMessages(currentLocationMessage)
        }
        
    }
    /********** ADDING CONTACTS **********/
    @IBAction func onAddContactButton(sender: AnyObject) {
        self.performSegueWithIdentifier("mainToAddressBookSegue", sender: nil)
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
//            addContactButton.userInteractionEnabled = false
//            addContactButton.titleLabel?.textColor = addContactButton.tintColor
        } else {
            print("User interaction with add contact is true")
//            addContactButton.userInteractionEnabled = true
//            addContactButton.titleLabel?.textColor = UIColor.whiteColor()
        }
        
        print(" RETRIEVING TOP THREE - User's top three contacts: \(User._currentUser?.contactsArray)")
        setUpContactButtons()
    }

    
    /********** CALLING CONTACTS **********/
    
    @IBAction func onFirstContactButton(sender: UILongPressGestureRecognizer) {
       // callContact(0)
    }
   
    @IBAction func onSecondContactButton(sender: UILongPressGestureRecognizer) {
       // callContact(1)
    }
    @IBAction func onThirdContactButton(sender: UILongPressGestureRecognizer) {
       // callContact(2)
    }
    
    /*func callContact(index: Int) {
        if(!firstContactButton.hidden) {
            let fullName = currentTopThree[index].keys.first! as String
            let phoneNumber = currentTopThree[index][fullName]
            if let url = NSURL(string: "tel://\(phoneNumber!)") {
                UIApplication.sharedApplication().openURL(url)
                print("Calling \(fullName)")
            } else {
                print("Cannot call \(fullName)")
            }
        } else {
            print("User does not have any contacts listed, go add some!")
        }
    }*/
    
    /********* AUTOMATED TEXT MESSAGES *********/
    func sendAutomatedTextMessages(message: String) {
        for i in 0 ..< currentTopThree.count {
            let fullName = currentTopThree[i].keys.first! as String
            let fullNameArr = fullName.componentsSeparatedByString(" ")
            let firstName = fullNameArr[0]
            var phoneNumber = currentTopThree[i][fullName]
            if (String(phoneNumber![(phoneNumber?.startIndex.advancedBy(0))!]) != "1") {
                phoneNumber = "1" + phoneNumber!
            }
            twilioAPICall(phoneNumber!, contactName: firstName, message: message)
        }
    }
    
    func twilioAPICall(phoneNumber: String, contactName: String, message: String) {
        //Message needs to be changed to have the user's current location and desired final destination
        let fullNameArr = User._currentUser?.name!.componentsSeparatedByString(" ")
        let userFirstName = fullNameArr![0]
        let toNumber = "%2B\(phoneNumber)"
        let greeting = "Yo \(contactName), \(userFirstName)"
        
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioAccountSID):\(twilioAuthToken)@api.twilio.com/2010-04-01/Accounts/\(twilioAccountSID)/SMS/Messages")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "From=%2B15106803810&To=\(toNumber)&Body=\(greeting+message)".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Build the completion block and send the request
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            print("Finished")
            if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                // Success
                print("Response: \(responseDetails)")
                print("Success")
//                dispatch_async(dispatch_get_main_queue()) {
//
//                }
                
            } else {
                // Failure
                print("Error: \(error)")
//                dispatch_async(dispatch_get_main_queue()) {
//
//                }
            }
        }).resume()
    }

    
    /*********** LOCATION MANAGER ***********/
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            currentLocation = location.coordinate

            // mapView.settings.myLocationButton = true
            mapView.setMinZoom(10, maxZoom: 18)
            
            if !pinchedOrPanned {
                if !started && endingMarker != nil {
                    let bounds = GMSCoordinateBounds(coordinate: currentLocation, coordinate: destinationLocation)
                    // Insets are specified in this order: top, left, bottom, right
                    let camera = self.mapView.cameraForBounds(bounds, insets: UIEdgeInsetsMake(self.CONTACT_WIDTH.constant * 1.5, self.CONTACT_WIDTH.constant * 1.5, self.CONTACT_WIDTH.constant * 1.5, self.CONTACT_WIDTH.constant * 2))!
                    
                    let update = GMSCameraUpdate.setCamera(camera)
                    self.mapView.animateWithCameraUpdate(update)
                } else {
                    let update = GMSCameraUpdate.setTarget(location.coordinate, zoom: DEFAULT_ZOOM)
                    mapView.animateWithCameraUpdate(update)
                }
            }
            
            if started {
                path.addCoordinate(currentLocation)
                if route != nil {
                    route.map = nil
                }
                
                route = GMSPolyline(path: path)
                route.strokeWidth = 5
                route.map = mapView
                
                let current = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                
                if destinationAddress != nil {
                    let destination = CLLocation(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude)
                    
                    let distance = current.distanceFromLocation(destination)
                    
                    print("distance is \(distance)")
                    if !safe && distance < 90 {
                        safe = true
                        bringUpSafe()
                    }
                }
            }
            
            //manager.stopUpdatingLocation()
            //_ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(turnOnLocation(_:)), userInfo: nil, repeats: false)
        }
    }
    
    @IBAction func onPinchedMap(sender: AnyObject) {
        pinchedOrPanned = true
        unclickedLocationButton(locationButton)
    }
    
    
    @IBAction func onPannedMap(sender: AnyObject) {
        onPinchedMap(self)
    }
    
    func turnOnLocation(sender: NSTimer) {
        locationManager.startUpdatingLocation()
    }
    
    /*********** CHECK-IN **********/
    func restartTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(CHECKIN_TIME, target:self, selector: #selector(MainViewController.popoutCheckIn), userInfo: nil, repeats: true)
    }
    
    func popoutCheckIn() {
        timer.invalidate()

        performSegueWithIdentifier("checkInSegue", sender: self)
    }
    
    /*********** START & SAFE BUTTON ***********/
    
    @IBAction func onStartButton(sender: AnyObject) {
        let textFieldInsideUISearchBar = self.searchController?.searchBar.valueForKey("searchField") as? UITextField
        hasDestination = (destinationAddress != nil && textFieldInsideUISearchBar?.text?.characters.count > 0)
        
        
        let clatitude = String(currentLocation.latitude)
        let clongitude = String(currentLocation.longitude)
        let currentLocationLink = "https://www.google.com/maps/preview/@\(clatitude),\(clongitude),16z"
        
        let firstMessage = " is using the Adiona app and has asked you to watch over them."
        let currentLocationMessage = "'s current location \(currentLocationLink)."
        
        if(!currentTopThree.isEmpty) {
            if !safe {
                startingLocation = currentLocation
                pinchedOrPanned = false
                
                let update = GMSCameraUpdate.setTarget(currentLocation, zoom: DEFAULT_ZOOM)
                mapView.animateWithCameraUpdate(update)

                restartTimer()
                startJourney()
                
                if !hasDestination! {
                    let textFieldInsideUISearchBar = searchController?.searchBar.valueForKey("searchField") as? UITextField
                    textFieldInsideUISearchBar?.textColor = UIColor.darkGrayColor()
                    textFieldInsideUISearchBar?.text = "No Destination"
                    sendAutomatedTextMessages(firstMessage)
                    sendAutomatedTextMessages(currentLocationMessage)
                    safe = true
                    bringUpSafe()
                } else {
//                    let dlatitude = String(destinationLocation.latitude)
//                    let dlongitude = String(destinationLocation.longitude)
//                    let destinationLink = "https://www.google.com/maps/preview/@\(dlatitude),\(dlongitude),16z"
//                    let destinationLocationMessage = " is traveling here: \(destinationLink)."
//                    sendAutomatedTextMessages(firstMessage)
//                    sendAutomatedTextMessages(currentLocationMessage)
//                    sendAutomatedTextMessages(destinationLocationMessage)
                }
            } else {
                let lastMessage = " has ended their journey safely, thanks for watching them!"
                let finalLocationLink = "'s final location: \(currentLocationLink)."
                safeJourney()
                sendAutomatedTextMessages(lastMessage)
                sendAutomatedTextMessages(finalLocationLink)
                timer.invalidate()
            }
        } else {
            print("User must add contacts to begin journey!")
            print("Add alert view controller")
            let alertController = UIAlertController(title: "You cannot start!", message: "Please add contacts before you begin your journey with Adiona.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true) { }
        }
        
        /* if hasDestination {
            if !safe {          // start button was pressed
                pinchedOrPanned = false
 
                let update = GMSCameraUpdate.setTarget(currentLocation, zoom: DEFAULT_ZOOM)
                mapView.animateWithCameraUpdate(update)
                
                startJourney()
            } else {            // safe button was pressed
                safeJourney()
            }
        } else {
            startingLocation = currentLocation
            
            if !safe {         // start button was pressed
                let textFieldInsideUISearchBar = searchController?.searchBar.valueForKey("searchField") as? UITextField
                textFieldInsideUISearchBar?.textColor = UIColor.darkGrayColor()
                textFieldInsideUISearchBar?.text = "No Destination"
                
                let update = GMSCameraUpdate.setTarget(currentLocation, zoom: DEFAULT_ZOOM)
                mapView.animateWithCameraUpdate(update)
                
                startJourney()
                safe = true
                bringUpSafe()
            } else {        // safe button was pressed
                safeJourney()
            }
        } */
    }
    
    func startJourney() {
        started = true
        disableSearch()
        
        // Starting Marker
        MapClient.sharedInstance.getLocationFromCoords(self.startingLocation, success: { (location: Location) in
            
            self.startingMarker = GMSMarker()
            self.startingMarker.position = self.startingLocation
            self.startingMarker.snippet = location.address
            self.startingMarker.map = self.mapView
            
            
            Location.getPlaceName(location.placeID, placesClient: self.placesClient, success: { (placeName: String) in
                self.startingMarker.title = placeName
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
            
            }, failure: { (error: NSError) in
                print(error.localizedDescription)
        })
    }
    
    func clearJourney() {
        if startingMarker != nil {
            startingMarker.map = nil
        }
        
        if endingMarker != nil {
            endingMarker.map = nil
        }
        
        if route != nil {
            route.map = nil
        }
    }
    
    func safeJourney() {
        if recOn {
            onRecButton(self)
        }
        
        renableSearch()
        self.startSafeButton.setTitle("START", forState: .Normal)

        clearJourney()
        safe = false
        started = false
        xMark.hidden = true
    }
    
    func bringUpSafe() {
        self.startSafeButton.setTitle("SAFE", forState: .Normal)
        
        self.BOTTOM_START_SAFE_BUTTON.constant = 0
        UIView.animateWithDuration(0.4, delay: 0.1, options: [], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func cancelStart(sender: UIBarButtonItem)
    {
        timer.invalidate()
        performSegueWithIdentifier("cancelTripSegue", sender: self)
        
    }
    
    func tripEnded(ended: Bool) {
        if ended {
            if recOn {
                onRecButton(self)
            }
            
            if !safe {
                self.BOTTOM_START_SAFE_BUTTON.constant = 0
                UIView.animateWithDuration(0.4, delay: 0.1, options: [], animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            } else {
                safe = false
                self.startSafeButton.setTitle("START", forState: .Normal)
            }
            
            renableSearch()
            clearJourney()
            started = false
            destinationAddress = nil
        }
    }
    
    func renableSearch() {
        path = GMSMutablePath()
        
        self.navigationItem.rightBarButtonItem = nil
        
        let textFieldInsideUISearchBar = searchController?.searchBar.valueForKey("searchField") as? UITextField
        
        textFieldInsideUISearchBar!.leftViewMode = UITextFieldViewMode.Always
        textFieldInsideUISearchBar!.clearButtonMode = UITextFieldViewMode.Always
        textFieldInsideUISearchBar!.textAlignment = NSTextAlignment.Left;
        
        textFieldInsideUISearchBar?.backgroundColor = UIColor.whiteColor()
        
        textFieldInsideUISearchBar!.enabled = true
        textFieldInsideUISearchBar!.textColor = UIColor.grayColor()
        textFieldInsideUISearchBar?.text = ""
    }
    
    func disableSearch() {
        self.BOTTOM_START_SAFE_BUTTON.constant = -1 * self.BUTTON_HEIGHT.constant
        UIView.animateWithDuration(0.4, delay: 0.1, options: [], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        let textFieldInsideUISearchBar = self.searchController?.searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideUISearchBar?.backgroundColor = UIColor.clearColor()
        
        textFieldInsideUISearchBar!.leftViewMode = UITextFieldViewMode.Never
        textFieldInsideUISearchBar!.clearButtonMode = UITextFieldViewMode.Never
        textFieldInsideUISearchBar!.textAlignment = NSTextAlignment.Center
        
        textFieldInsideUISearchBar!.enabled = false
        textFieldInsideUISearchBar!.textColor = UIColor.blackColor()
        
        self.cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.cancelStart(_:)))
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }
    
    /*********** VIDEO RECORDING IMPLEMENTATION ***********/
    
    func setupCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if device.hasMediaType(AVMediaTypeVideo) {
                if device.position == .Back {
                    captureDevice = device as? AVCaptureDevice
                }
            }
            
            if device.hasMediaType(AVMediaTypeAudio) {
                audioDevice = device as? AVCaptureDevice
            }
        }
        
        captureSession.beginConfiguration()
        captureSession.addOutput(captureOutput)
        
        let deviceInput: AVCaptureDeviceInput?
        
        if captureDevice != nil {
            do {
                deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            } catch {
                deviceInput = nil
                print("Error: Creating deviceInput")
            }
            
            if deviceInput != nil {
                captureSession.addInput(deviceInput)
            }
        }
        
        let audioInput: AVCaptureDeviceInput?
    
        if audioDevice != nil {
            do {
                audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            } catch {
                audioInput = nil
                print("ERROR: Creating audioInput")
            }
            
            if audioInput != nil {
                captureSession.addInput(audioInput)
            }
        }
        
        captureSession.commitConfiguration()
    }

    @IBAction func onRecButton(sender: AnyObject) {
        if !started {
            if captureSession.inputs.count == 0 {
                backCameraError()
            } else {
                let alertController = UIAlertController(title: "You cannot record yet!", message: "Please start a journey before you start recording.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    //action here
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return
        }
        
        if !recOn {
            if captureSession.inputs.count > 0  && captureDevice != nil {
                videoView.userInteractionEnabled = true
                
                recButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                recButton.layer.borderColor = UIColor.redColor().CGColor
                
                recOn = true
                livePreview()
                
                captureSession.startRunning()
                captureOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputPath), recordingDelegate: self)
                
            } else {
                print("ERROR: Device does not have back camera")
                backCameraError()
            }
            
        } else {
            if captureSession.inputs.count > 0  && captureDevice != nil {
                dimRecord()
                origVideoView()
                
                recOn = false
                videoView.hidden = true
                xMark.hidden = true
                
                captureSession.stopRunning()
                captureOutput.stopRecording()
                
                navigationController?.navigationBarHidden = false
                videoView.userInteractionEnabled = false
                mapView.userInteractionEnabled = true
            } else {
                print("ERROR: Device does not have back camera")
                backCameraError()
            }
        }
    }
    
    func backCameraError() {
        let alertController = UIAlertController(title: "You cannot record!", message: "Please give us access to your camera to begin.", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            //action here
        }
        
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("finished recording")
        
        let alertController = UIAlertController(title: "You made a recording.", message: "What do you want to do with it?", preferredStyle: .ActionSheet)
        let noAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            //action here
        }
        let yesAction = UIAlertAction(title: "Save to Camera Roll", style: .Default) { (action) in
            UISaveVideoAtPathToSavedPhotosAlbum(self.outputPath, self, nil, nil)
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("started recording")
        return
    }
    
    /*********** VIDEO RECORDING EXPANSION ***********/
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func videoExpanded(sender: UILongPressGestureRecognizer) {
        navigationController?.navigationBarHidden = true
        
        self.videoViewHeight.constant = self.mapView.frame.height
        self.videoViewWidth.constant = self.mapView.frame.width
        
        self.videoView.layer.cornerRadius = 0
        self.videoView.userInteractionEnabled = false
        
        self.boundsLivePreview()
        
        self.videoViewFrameTop.constant = 0
        self.videoViewFrameLeft.constant = 0
        
        self.videoView.layoutIfNeeded()
        
        self.xMark.hidden = false
        self.mapView.userInteractionEnabled = false
    }
    
    @IBAction func onXMark(sender: AnyObject) {
        origVideoView()
        
        self.boundsLivePreview()
        self.videoView.layoutIfNeeded()
        
        self.xMark.hidden = true
        self.mapView.userInteractionEnabled = true
        
    }
    
    func origVideoView() {
        navigationController?.navigationBarHidden = false
        
        self.videoViewFrameTop.constant = self.origVidViewTop
        self.videoViewFrameLeft.constant = self.origVidViewLeft
        
        self.videoViewHeight.constant = self.origVidViewSize
        self.videoViewWidth.constant = self.origVidViewSize
        
        self.videoView.layer.cornerRadius = self.VIDEO_RADIUS
        self.videoView.userInteractionEnabled = true
        
        self.videoView.layer.bounds = CGRect(x: self.origVidViewLeft, y: self.origVidViewTop, width: self.origVidViewSize, height: self.origVidViewSize)
    }
    
    func livePreview() {
        videoView.hidden = false
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        boundsLivePreview()
        self.videoView.layoutIfNeeded()
    }
    
    func boundsLivePreview() {
        let bounds:CGRect = videoView.layer.bounds
        videoPreviewLayer!.bounds = bounds
        
        videoPreviewLayer!.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        
        videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        videoView.layer.addSublayer(videoPreviewLayer!)
        videoView.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    func videoPanned(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            originalCenter = videoView.center
            UIView.animateWithDuration(0.4, delay: 0.0, options: [], animations: {
                self.videoView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: nil)
        } else if sender.state == UIGestureRecognizerState.Changed {
            let translationX = originalCenter.x + translation.x
            let translationY = originalCenter.y + translation.y
            
            // Prevent the video view from hitting navigation bar, buttons, and contacts
            if translationX > videoView.frame.width/2 && translationX < view.frame.width - CONTACT_WIDTH.constant - videoView.frame.width/2 - 5 {
                if translationY > NAVIGATION_HEIGHT + videoView.frame.height/2 + 15 {
                    if translationY < view.frame.height - BUTTON_HEIGHT.constant - SMALL_BUTTON_HEIGHT.constant - videoView.frame.height/2 - 10 {
                        videoView.center = CGPoint(x: translationX, y: translationY)
                    }
                }
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: {
                self.videoView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "iffySegue" {
            let vc = segue.destinationViewController as! IffyViewController
            vc.delegate = self
            vc.currentLocation = currentLocation   
        } else if segue.identifier == "settingsSideMenuSegue" {
            let sideMenuNC: SideMenuNC = segue.destinationViewController as! SideMenuNC
            sideMenuNC.buttonDelegate = self
            let vc = sideMenuNC.viewControllers.first as! SettingsMenuVC
            vc.mainVC = self
        } else if segue.identifier == "mainToAddressBookSegue" {
            print("going to address book!")
            let addressBookVC: AddressBookVC = segue.destinationViewController as! AddressBookVC
            addressBookVC.delegate = self
        } else if segue.identifier == "cancelTripSegue" {
            let vc = segue.destinationViewController as! CancelPinViewController
            vc.delegate = self
            vc.currentLocation = currentLocation
            
            print("cancelled trip")
        } else if segue.identifier == "checkInSegue" {
            let vc = segue.destinationViewController as! CheckInViewController
            vc.delegate = self
            vc.currentLocation = currentLocation
            print("checked in")
        } else if segue.identifier == "filterSideMenuSegue" {
            let sideMenuNC = segue.destinationViewController as! UISideMenuNavigationController
            let vc = sideMenuNC.viewControllers.first as! FilterVC
            vc.mainVC = self
        } else if segue.identifier == "contactPopoverSegue" {
            
            // Show popover
            let popoverViewController = segue.destinationViewController as! PopupContactViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            if let popover = popoverViewController.popoverPresentationController, sourceView = sender as? UIView {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
            }
            
            // Check which button
            let button = sender as! UIButton
            if button == firstContactButton {
                let fullName = currentTopThree[0].keys.first! as String
                popoverViewController.fullName  = fullName
                popoverViewController.phoneNumber = currentTopThree[0][fullName]
            } else if button == secondContactButton {
                let fullName = currentTopThree[1].keys.first! as String
                popoverViewController.fullName  = fullName
                popoverViewController.phoneNumber = currentTopThree[1][fullName]
            } else if button == thirdContactButton {
                let fullName = currentTopThree[2].keys.first! as String
                popoverViewController.fullName  = fullName
                popoverViewController.phoneNumber = currentTopThree[2][fullName]
            }
            
            // Dim entire view
            let dimView = UIView(frame: view.frame)
            view.addSubview(dimView)
            dimView.backgroundColor = UIColor.blackColor()
            dimView.alpha = 0.5
            dimView.tag = 1234
            dimView.userInteractionEnabled = false
            
            popoverViewController.delegate = self
            
            UIApplication.sharedApplication().keyWindow!.addSubview(dimView)
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func dimScreen() {
        for subView in UIApplication.sharedApplication().keyWindow!.subviews {
            if subView.tag == 1234 {
                UIView.animateWithDuration(0.1, animations: {
                    subView.alpha = 0.0
                    }, completion: { (Bool) in
                        subView.removeFromSuperview()
                })
                
            }
        }
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        dimScreen()
    }
}

extension MainViewController: IffyDelegate {
    func submitData(reasons: [String]) {
        let data = Iffy(location: currentLocation, reasons: reasons)
        data.postToParse { (success: Bool, error: NSError?) in
            if success {
                // add created marker to map
                if !data.filteredOut {
                    self.loadingSafetyLabel.hidden = false
                    self.clusterManager.addItem(data)
                    self.clusterManager.cluster()
                    self.loadingSafetyLabel.hidden = true
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}

extension MainViewController: GMSMapViewDelegate {
    func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
        print("location button tapped")
        pinchedOrPanned = false
        return false
    }
    
    @IBAction func onMyLocationButton(sender: AnyObject) {
        let update = GMSCameraUpdate.setTarget(currentLocation, zoom: DEFAULT_ZOOM)
        mapView.animateWithCameraUpdate(update)
        unclickedLocationButton(locationButton)
        pinchedOrPanned = false
    }
    
    
    @IBAction func offMyLocationButton(sender: AnyObject) {
        clickedLocationButton(locationButton)
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if marker != startingMarker && marker != endingMarker {
            mapView.selectedMarker = marker
            return true
        }
        return false
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        guard marker != startingMarker && marker != endingMarker else {
            return nil
        }
        
        return makeClusterInfoWindow(marker)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            if endingMarker != nil {
                endingMarker.map = nil
                
                let update = GMSCameraUpdate.setTarget(currentLocation, zoom: DEFAULT_ZOOM)
                mapView.animateWithCameraUpdate(update)
                pinchedOrPanned = false
            }
        }
    }
}

extension MainViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWithPlace place: GMSPlace) {
        searchController?.active = false
        
        clearJourney()
        
        //SearchBar Text
        let textFieldInsideUISearchBar = searchController?.searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideUISearchBar?.textColor = UIColor.darkGrayColor()
        if (place.formattedAddress!).rangeOfString(place.name) != nil {
            textFieldInsideUISearchBar?.text = "\(place.formattedAddress!)"
        } else {
            textFieldInsideUISearchBar?.text = "\(place.name), \(place.formattedAddress!)"

        }
        
        destinationName = place.name
        destinationAddress = place.formattedAddress
        getRoute()
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: NSError){
        print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func getRoute() {
        startingLocation = currentLocation
        
        MapClient.sharedInstance.directionFrom(startingLocation, destination: destinationAddress, success: { (dest: Destination) in
            
            // Move to distance difference
            let bounds = GMSCoordinateBounds(coordinate: self.currentLocation, coordinate: dest.endCoords)
            // Insets are specified in this order: top, left, bottom, right
            let camera = self.mapView.cameraForBounds(bounds, insets: UIEdgeInsetsMake(self.CONTACT_WIDTH.constant * 1.5, self.CONTACT_WIDTH.constant * 1.5, self.CONTACT_WIDTH.constant * 1.5, self.CONTACT_WIDTH.constant * 2))!
            
            let update = GMSCameraUpdate.setCamera(camera)
            self.mapView.animateWithCameraUpdate(update)
            
            // Ending Marker
            self.destinationLocation = dest.endCoords
            
            self.endingMarker = GMSMarker()
            self.endingMarker.position = dest.endCoords
            self.endingMarker.title = self.destinationName
            self.endingMarker.snippet = self.destinationAddress
            self.endingMarker.map = self.mapView
            self.endingMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            
            
        }) { (error: NSError) in
            if error.code == -42 {
                print(error.localizedDescription)
                
                let alertController = UIAlertController(title: "Uh oh!", message: "No route was found to your destination. Please type a different location.", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    //action here
                }
                alertController.addAction(OKAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    
    
    
}
