//
//  CreatePublicEventViewController.swift
//  Backflip
//
//  Created by Cody Mazza-Anthony on 2015-06-11.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import DigitsKit


class CreatePublicEventViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBAction func settingButton(sender: AnyObject) {
        displayAlertLogout("Would you like to log out?", error: "")
    }
    
    var logoutButton = UIImage(named: "settings-icon") as UIImage!
    
    var userGeoPoint = PFGeoPoint()
    
    @IBAction func joinEvent(sender: AnyObject) {
        
        tabBarController?.selectedIndex = 0
    }
    // Quality of service variable for threading
    let qos = (Int(QOS_CLASS_BACKGROUND.rawValue))
    
    @IBOutlet var addressText: UIImageView!
    
    // @IBOutlet weak var albumview: AlbumViewController?
    // Disable navigation
    override func viewWillAppear(animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
		#if FEATURE_GOOGLE_ANALYTICS
            
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Create Public Event")
            //tracker.set("&uid", value: PFUser.currentUser()?.objectId)
            tracker.set(GAIFields.customDimensionForIndex(2), value: PFUser.currentUser()?.objectId)
            
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
		#endif
    }
    var address2:String = ""
    
    var locationDisabled = false
    
    @IBOutlet var eventName: UITextField!
    
    @IBOutlet var userAddressButton: UIButton!
    
    var eventID : String?
    
    
    @IBOutlet var addressField: UILabel!
    
    
    func displayAlert(title:String, error: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func displayAlertLogout(title:String, error: String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { action in
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            self.hidesBottomBarWhenPushed = true
            self.performSegueWithIdentifier("logoutCreatePublic", sender: self)
            
            
        }))
		
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayNoInternetAlert() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
            self.presentViewController(alert, animated: true, completion: nil)
            print("no internet")
        })
    }
    
    func getUserAddress() {
        let userLatitude = self.userGeoPoint.latitude
        let userLongitude = self.userGeoPoint.longitude
        
        if (self.locationDisabled == true) {
            self.addressField.text = "No location found"
        } else {
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: userLatitude, longitude: userLongitude)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                if (error == nil) {
                    let placeArray = placemarks!
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray[0]
                    
                    // Address dictionary
                    //println(placeMark.addressDictionary)
                    
                    // Location name
                    var streetNumber = ""
                    if let locationName = placeMark.addressDictionary?["Name"] as? NSString {
                        print(locationName)
                        streetNumber = locationName as String
                    }
                    
                    var streetAddress = ""
                    // Street address
                    if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString {
                        print(street)
                        streetAddress = street as String
                    }
                    
                    var cityName = ""
                    // City
                    if let city = placeMark.addressDictionary?["City"] as? NSString {
                        print(city)
                        cityName = city as String
                        
                    }
                    
                    // Zip code
                    if let zip = placeMark.addressDictionary?["ZIP"] as? NSString {
                        print(zip)
                    }
                    
                    // Country
                    var countryName = ""
                    if let country = placeMark.addressDictionary?["Country"] as? NSString {
                        print(country)
                        countryName = country as String
                    }
                    
                    let address = streetNumber + ", " + streetAddress
                    self.address2 = streetNumber + ", " + cityName + ", " + countryName
                    self.addressField.text = address
                } else {
                    self.displayNoInternetAlert()
                    print("could not generate location - no internet")
                    self.address2 = "No location found"
                    self.addressField.text = self.address2
                }
            })
        }
    }
    
    @IBAction func createEvent(sender: AnyObject) {
        
        var error = ""
        
        let address = self.addressField.text
        
        //Limit number of characters in event name (Make sure not 0 characters)
        let myStr = self.eventName.text!
        let eventName = myStr as String
        
        if (locationDisabled == true) {
            error = "Please enable location access in the iOS settings for Backflip."
        } else if (eventName == "") {// || address == "") {
            error = "Please enter an event name."
        } else if (eventName.characters.count < 2) {
            error = "Please enter a valid event name."
        }
        
        if error == "Please enter an event name." {
            
            noNameAlert()
            
        } else if (error != "") {
            
            displayAlert("Couldn't Create Event", error: error)
            
        } else {
            if NetworkAvailable.networkConnection() == true {
				
				// Display a HUD letting the user know we're checking them in
				PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Creating Event..")
				PKHUD.sharedHUD.show()
				
                let query = PFUser.query()
                query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                    if error != nil {
                        print(error)
						PKHUD.sharedHUD.hideAnimated()
                        
                    } else {
                        
                        let event = PFObject(className: "Event")
                        
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                            //print(placemarks?[0])
                            
							if let placemark : CLPlacemark = placemarks![0] {
								let location : CLLocation = placemark.location!
                                let eventLatitude = location.coordinate.latitude
                                let eventLongitude = location.coordinate.longitude
                                
                                let userGeoPoint = PFGeoPoint(latitude:eventLatitude, longitude:eventLongitude)
                                
                                self.userGeoPoint = userGeoPoint
								
                            }
                        })
						
						
						
                        // Put querying into a background thread
						dispatch_async(dispatch_get_global_queue(self.qos,0), { () -> Void in
                            event["geoLocation"] = self.userGeoPoint
                            
                            //Check if event already exists
                            let query = PFQuery(className: "Event")
                            query.whereKey("eventName", equalTo: eventName)
                            let scoreArray = query.findObjects()
                            
                            if (scoreArray != nil) {
                                if (scoreArray!.count == 0) {
                                    event["eventName"] = eventName
                                    event["venue"] = address
                                    event["startTime"] = NSDate()
                                    event["isLive"] = true
									event["enabled"] = true
                                    let eventACL = PFACL(user: PFUser.currentUser()!)
                                    eventACL.setPublicWriteAccess(true)
                                    eventACL.setPublicReadAccess(true)
                                    event.ACL = eventACL
                                    
                                    // Store the relation
                                    let relation = event.relationForKey("attendees")
                                    relation.addObject(PFUser.currentUser()!)
                                    
                                    self.eventID = event.objectId
                                    event.save()
                                    
                                    object?.addUniqueObject(event, forKey:"savedEvents")
                                    object?.addUniqueObject(eventName, forKey:"savedEventNames")
                                    
                                    object!.save()
									
                                    // Add the EventAttendance join table relationship for photos (liked and uploaded)
                                    let attendance = PFObject(className:"EventAttendance")
                                    attendance["eventID"] = event.objectId
                                    //let temp = PFUser.currentUser()?.objectId// as String
                                    attendance["attendeeID"] = PFUser.currentUser()?.objectId
                                    attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                                    attendance.setObject(event, forKey: "event")
                                    attendance["photosLikedID"] = []
                                    attendance["photosLiked"] = []
                                    attendance["photosUploadedID"] = []
                                    attendance["photosUploaded"] = []
									attendance["enabled"] = true
                                    
                                    attendance.save()
									
									BFDataProcessor.sharedProcessor.processEvents([event], completion: { () -> Void in
										
										// Store event details in user defaults
										NSUserDefaults.standardUserDefaults().setValue(event.objectId!, forKey: "checkin_event_id")
										NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: "checkin_event_time")
										NSUserDefaults.standardUserDefaults().setValue(eventName, forKey: "checkin_event_name")
										
										// When successful, segue to events page
										dispatch_async(dispatch_get_main_queue()) {
											
											print("Saved")
											PKHUD.sharedHUD.hideAnimated()
											// self.albumview?.eventId = self.eventID
											//self.performSegueWithIdentifier("eventsPage", sender: self)
											self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
										}
										
									})
									
                                } else {
                                    self.displayAlert("This event already exists", error: "Join an existing event on the Nearby Events screen.")
                                }
                            } else {
                                self.displayNoInternetAlert()
                            }
                        })
                    }
                })
            } else {
                displayNoInternetAlert()
            }
        }
    }

//    // Add event to event class
//    @IBAction func createEvent(sender: AnyObject) {
//            }
    
    // Function to grey out create event button unless more than 2 characters are entered
    func textCheck (sender: AnyObject) {
        
        let textField = sender as! UITextField
        var resp : UIResponder = textField
        while !(resp is UIAlertController) { resp = resp.nextResponder()!}
        let alert = resp as! UIAlertController
        alert.actions[1].enabled = (textField.text!.characters.count > 1)
        
    }
    
    // Delegate method to prevent typing in text over 25 characters in alertview
    // http://stackoverflow.com/questions/433337/set-the-maximum-character-length-of-a-uitextfield
    // Information on how this delegate method works
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location > textField.text!.characters.count )
        {
            return false;
        }
        
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= 25
    }
    
    // Function displaying alert when creating an event that has no content in it
    func noNameAlert() {
        let alert = UIAlertController(title: "Please enter an event name.", message: "Event name:", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.Default, handler: { (action) in
            
                // Content that is in textfield when create is pressed
                let eventTitle = alert.textFields!.first!
                
                let address = self.addressField.text
                
                let eventName = eventTitle.text
                print(eventName)
                
                let query = PFUser.query()
                query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                    
                    if error != nil {
                        print(error)
                    } else {
                        
                        let event = PFObject(className: "Event")
						let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(address!, completionHandler: {( placemarks: [CLPlacemark]?, error: NSError?) -> Void in
							if let placemark : CLPlacemark = placemarks![0] {
								
								let location : CLLocation = placemark.location!
                                let eventLatitude = location.coordinate.latitude
                                let eventLongitude = location.coordinate.longitude
                                
                                let userGeoPoint = PFGeoPoint(latitude: eventLatitude, longitude: eventLongitude)
                                
                                self.userGeoPoint = userGeoPoint
                            }
                        })
                        
                        
                        dispatch_async(dispatch_get_global_queue(self.qos, 0)) {
                            
                            event["geoLocation"] = self.userGeoPoint
                            
                            // Query for event names
                            let queryEvent = PFQuery(className: "Event")
                            queryEvent.whereKey("eventName", equalTo: eventName!)
                            let scoreArray = queryEvent.findObjects()
                            
                            // Nil means no connection established, count of 0 means no other events exist of the same name
                            if (scoreArray != nil) {
                                if (scoreArray!.count == 0) {
                                    
                                    event["eventName"] = eventName
                                    event["venue"] = address
                                    event["startTime"] = NSDate()
                                    event["isLive"] = true
                                    
                                    // Set access rules for events
                                    let eventACL = PFACL(user: PFUser.currentUser()!)
                                    eventACL.setPublicReadAccess(true)
                                    eventACL.setPublicWriteAccess(true)
                                    event.ACL = eventACL
                                    
                                    // Store the relation into the Parse Database
                                    let relation = event.relationForKey("attendees")
                                    relation.addObject(PFUser.currentUser()!)
                                    
                                    self.eventID = event.objectId
                                    event.save()
                                    
                                    // Add the event name and object to the Users profile
                                    object?.addUniqueObject(event, forKey: "savedEvents")
                                    object?.addUniqueObject(eventName!, forKey: "savedEventNames")
                                    object!.save()
                                    
                                    // Add relationship in the EventAttendance join table
                                    let attendance = PFObject(className: "EventAttendance")
                                    attendance["eventID"] = event.objectId
                                    attendance["attendeeID"] = PFUser.currentUser()?.objectId
                                    attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                                    attendance.setObject(event, forKey: "event")
                                    attendance["photosLikedID"] = []
                                    attendance["photosLiked"] = []
                                    attendance["photosUploadedID"] = []
                                    attendance["photosUploaded"] = []
                                    
                                    attendance.save()
                                    
                                    // Store event details in user defaults
                                    NSUserDefaults.standardUserDefaults().setValue(event.objectId!, forKey: "checkin_event_id")
                                    NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: "checkin_event_time")
                                    NSUserDefaults.standardUserDefaults().setValue(eventName, forKey: "checkin_event_name")

                                    // Upon successful add to DB, segue to the events page
                                    dispatch_async(dispatch_get_main_queue()) {
                                        
                                        print("Saved")
                                        // self.albumview?.eventId = self.eventID
                                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                                    }
                                } else {
                                    self.displayAlert("This event already exists", error: "Please try again")
                                }
                            } else {
                                self.displayNoInternetAlert()
                            }
                        }
                    }
                })
        }))
        
        // Add target to function that checks the text input
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.addTarget(self, action: "textCheck:", forControlEvents: .EditingChanged)
            textField.delegate = self

        }
        
        // Add the cancel button, as well as disable interaction with create button until 2 or more characters present in textfield
        (alert.actions[1] ).enabled = false
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        //self.performSegueWithIdentifier("eventsPage", sender: self)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
	
	
	@IBAction func cancelButton()
	{
		self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	override func loadView()
	{
		super.loadView()
		
		// Backflip Logo
		self.navigationItem.titleView = UIImageView(image: UIImage(named: "backflip-logo-white"))
	}
	
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Makes the keyboard pop up as soon as the view appears
        eventName.becomeFirstResponder()
        
        //--------------- Draw UI ---------------
        
//        // Hide UI controller item
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        
//        // Nav Bar positioning
//        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 64))
//        navBar.backgroundColor =  UIColor.whiteColor()
//        
//        // Set the Nav bar properties
//        let navBarItem = UINavigationItem()
//        navBarItem.title = "Create An Event"
//        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
//        navBar.items = [navBarItem]
//        
//        // Left nav bar button item
//        let logout = UIButton.buttonWithType(.System) as! UIButton
//        logout.setImage(logoutButton, forState: .Normal)
//        logout.tintColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
//        logout.frame = CGRectMake(-10, 20, 72, 44)
//        logout.addTarget(self, action: "settingButton:", forControlEvents: .TouchUpInside)
//        navBar.addSubview(logout)
//        
//        self.view.addSubview(navBar)
        
        //Add delegate, this prevents users from typing text over 25 characters
        eventName.delegate = self
        
        if NetworkAvailable.networkConnection() == true {
            
            //getUserAddress()
            
            PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
                if error == nil {
                    print(geoPoint, terminator: "")
                    self.userGeoPoint = geoPoint!
                }
                else {
                    print("Error with User Geopoint")
                    self.locationDisabled = true
                }
            }
        } else {
            displayNoInternetAlert()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if NetworkAvailable.networkConnection() == true {
            getUserAddress()
        } else {
            displayNoInternetAlert()
        }

    }
    
    // Two functions to allow off keyboard touch to close keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func disablesAutomaticKeyboardDismissal() -> Bool {
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        eventName.resignFirstResponder()
        eventName.endEditing(true)
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
