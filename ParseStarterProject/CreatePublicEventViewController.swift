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


class CreatePublicEventViewController: UIViewController {
    
    
    @IBAction func settingButton(sender: AnyObject) {
        displayAlertLogout("Would you like to log out?", error: "")
    }
    
    var logoutButton = UIImage(named: "settings-icon") as UIImage!
    
    var userGeoPoint = PFGeoPoint()
    
    
    @IBOutlet var addressText: UIImageView!
    
    @IBOutlet weak var albumview: AlbumViewController?
    // Disable navigation
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    var address2:String = ""
    
    var locationDisabled = false
    
    @IBOutlet var eventName: UITextField!
    
    @IBOutlet var userAddressButton: UIButton!
    
    var eventID : String?
    
    
    @IBOutlet var addressField: UILabel!
    
    
    func displayAlert(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayAlertLogout(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .Default, handler: { action in
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            self.performSegueWithIdentifier("logoutCreatePublic", sender: self)
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayNoInternetAlert() {
        var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
        self.presentViewController(alert, animated: true, completion: nil)
        println("no internet")
    }
    
    func getUserAddress() {
        var userLatitude = self.userGeoPoint.latitude
        var userLongitude = self.userGeoPoint.longitude
        
        if (self.locationDisabled == true) {
            self.addressField.text = "No location found"
        } else {
            var geoCoder = CLGeocoder()
            var location = CLLocation(latitude: userLatitude, longitude: userLongitude)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                if (error == nil) {
                    let placeArray = placemarks as! [CLPlacemark]
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray[0]
                    
                    // Address dictionary
                    //println(placeMark.addressDictionary)
                    
                    // Location name
                    var streetNumber = ""
                    if let locationName = placeMark.addressDictionary["Name"] as? NSString {
                        //println(locationName)
                        streetNumber = locationName as String
                    }
                    
                    var streetAddress = ""
                    // Street address
                    if let street = placeMark.addressDictionary["Thoroughfare"] as? NSString {
                        //println(street)
                        streetAddress = street as String
                    }
                    
                    var cityName = ""
                    // City
                    if let city = placeMark.addressDictionary["City"] as? NSString {
                        //println(city)
                        cityName = city as String
                        
                    }
                    
                    // Zip code
                    if let zip = placeMark.addressDictionary["ZIP"] as? NSString {
                        //println(zip)
                    }
                    
                    // Country
                    var countryName = ""
                    if let country = placeMark.addressDictionary["Country"] as? NSString {
                        //println(country)
                        countryName = country as String
                    }
                    
                    var address = streetNumber + ", " + streetAddress
                    self.address2 = streetNumber + ", " + cityName + ", " + countryName
                    self.addressField.text = address
                } else {
                    self.displayNoInternetAlert()
                    println("could not generate location - no internet")
                    self.address2 = ""
                    self.addressField.text = self.address2
                }
            })
        }
    }
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (count(textField.text!) > maxLength) {
            textField.deleteBackward()
        }
    }

    // Add event to event class
    @IBAction func createEvent(sender: AnyObject) {
        
        var error = ""
        
        var address = self.addressField.text
        
        //Limit number of characters in event name
        var myStr = self.eventName.text as NSString
        if (count(self.eventName.text) > 25){
            displayAlert("Couldn't Create Event", error: "The name of your event is too long. Please keep it under 25 characters.")
        } else {
            var eventName = myStr as String
            
            if (locationDisabled == true) {
                error = "Please enable location access in the iOS settings for Backflip."
            } else if (eventName == "" || address == "") {
                error = "Please enter an event name."
            } else if (count(eventName) < 2) {
                error = "Please enter a valid event name."
            }
            
            if (error != "") {
                displayAlert("Couldn't Create Event", error: error)
            } else {
                if NetworkAvailable.networkConnection() == true {
                    let query = PFUser.query()
                    query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                        
                        //                var result = self.getUserLocationFromAddress()
                        
                        
                        if error != nil {
                            println(error)
                        }
                        else
                        {
                            
                            var event = PFObject(className: "Event")
                            
                            var geocoder = CLGeocoder()
                            geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                                //print(placemarks?[0])
                                
                                if let placemark = placemarks?[0] as? CLPlacemark {
                                    var location = placemark.location as CLLocation
                                    var eventLatitude = location.coordinate.latitude
                                    var eventLongitude = location.coordinate.longitude
                                    
                                    let userGeoPoint = PFGeoPoint(latitude:eventLatitude, longitude:eventLongitude)
                                    
                                    self.userGeoPoint = userGeoPoint
                                }
                            })
                            
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
                                    var eventACL = PFACL(user: PFUser.currentUser()!)
                                    eventACL.setPublicWriteAccess(true)
                                    eventACL.setPublicReadAccess(true)
                                    event.ACL = eventACL
                                    
                                    // Store the relation
                                    let relation = event.relationForKey("attendees")
                                    relation.addObject(PFUser.currentUser()!)
                                    
                                    self.eventID = event.objectId
                                    event.save()
                                    /*event.saveInBackgroundWithBlock({ (success, error) -> Void in
                                    if (success) {
                                    println("Objects has been successfully saved")
                                    } else {
                                    // There was a problem, check error.description
                                    println(error)
                                    }
                                    })*/
                                    
                                    object?.addUniqueObject(event, forKey:"savedEvents")
                                    object?.addUniqueObject(eventName, forKey:"savedEventNames")
                                    
                                    object!.save()
                                    
                                    // Add the EventAttendance join table relationship for photos (liked and uploaded)
                                    var attendance = PFObject(className:"EventAttendance")
                                    attendance["eventID"] = event.objectId
                                    //let temp = PFUser.currentUser()?.objectId// as String
                                    attendance["attendeeID"] = PFUser.currentUser()?.objectId
                                    attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                                    attendance.setObject(event, forKey: "event")
                                    attendance["photosLikedID"] = []
                                    attendance["photosLiked"] = []
                                    attendance["photosUploadedID"] = []
                                    attendance["photosUploaded"] = []
                                    
                                    attendance.save()
                                    
                                    println("Saved")
                                    self.albumview?.eventId = self.eventID
                                    self.performSegueWithIdentifier("eventsPage", sender: self)
                                    
                                } else {
                                    self.displayAlert("This event already exists", error: "Join an existing event below")
                                    
                                }
                            } else {
                                self.displayNoInternetAlert()
                            }
                        }
                    })
                }
                else {
                    displayNoInternetAlert()
                }
            }

        }
        
    }
    

    /*
    func getUserLocationFromAddress() -> NSString {
        var address = "1 Infinite Loop, CA, USA"
        var geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            println(error)
            if let placemark = placemarks?[0] as? CLPlacemark {
                println(placemark.location)
                println(placemark.location.coordinate.latitude)
                println(placemark.location.coordinate.longitude)
            }
        })
        
        return ""
    
    }
*/
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("eventsPage", sender: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //--------------- Draw UI ---------------
        
        // Hide UI controller item
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Nav Bar positioning
        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 64))
        navBar.backgroundColor =  UIColor.whiteColor()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()
        navBarItem.title = "Create An Event"
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let logout = UIButton.buttonWithType(.System) as! UIButton
        logout.setImage(logoutButton, forState: .Normal)
        logout.tintColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        logout.frame = CGRectMake(-10, 20, 72, 44)
        logout.addTarget(self, action: "settingButton:", forControlEvents: .TouchUpInside)
        navBar.addSubview(logout)
        
        self.view.addSubview(navBar)
        
        if NetworkAvailable.networkConnection() == true {
            PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
                if error == nil {
                    print(geoPoint)
                    self.userGeoPoint = geoPoint!
                }
                else {
                    println("Error with User Geopoint")
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
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
