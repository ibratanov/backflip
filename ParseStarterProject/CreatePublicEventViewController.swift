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
    
    // Disable navigation
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    var address2:String = ""
    
    @IBOutlet var eventName: UITextField!
    
    @IBOutlet var userAddressButton: UIButton!
    
    @IBOutlet var addressField: UITextField!
    
    
    func displayAlert(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayAlertLogout(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { action in
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            self.performSegueWithIdentifier("logoutCreatePublic", sender: self)
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func getUserAddressButton(sender: AnyObject) {
        
        var userLatitude = self.userGeoPoint.latitude
        var userLongitude = self.userGeoPoint.longitude
        
        
        var geoCoder = CLGeocoder()
        var location = CLLocation(latitude: userLatitude, longitude: userLongitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as! [CLPlacemark]
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray[0]
            
            // Address dictionary
            println(placeMark.addressDictionary)
            
            // Location name
            var streetNumber = ""
            if let locationName = placeMark.addressDictionary["Name"] as? NSString {
                println(locationName)
                streetNumber = locationName as String
            }
            
            var streetAddress = ""
            // Street address
            if let street = placeMark.addressDictionary["Thoroughfare"] as? NSString {
                println(street)
                streetAddress = street as String
            }
            
            var cityName = ""
            // City
            if let city = placeMark.addressDictionary["City"] as? NSString {
                println(city)
                cityName = city as String
                
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary["ZIP"] as? NSString {
                println(zip)
            }
            
            // Country
            var countryName = ""
            if let country = placeMark.addressDictionary["Country"] as? NSString {
                println(country)
                countryName = country as String
            }
            
            var address = streetNumber + ", " + streetAddress
            self.address2 = streetNumber + ", " + cityName + ", " + countryName
            self.addressField.text = address
            
            
        })
        
        self.userAddressButton.hidden = true
        
        var event = PFObject(className:"Event")
        event["eventName"] = self.eventName.text
        
        let userGeoPoint = PFGeoPoint(latitude:userLatitude, longitude:userLongitude)
        event["geoLocation"] = userGeoPoint
        
//        event.saveInBackgroundWithBlock {
//            (success: Bool, error: NSError?) -> Void in
//            if (success) {
//                // The object has been saved.
//                println("success \(event.objectId)")
//            } else {
//                // There was a problem, check error.description
//                println("fail")
//            }
//        }
    }

    
    // Add event to event class
    @IBAction func createEvent(sender: AnyObject) {
        
        var error = ""
        
        //var address = self.addressField.text
        
        var address = self.address2
        println("======================" + self.address2)
        
        // Template for address
        //var address = "289-303 Yonge St, Toronto, Canada"
        
        var eventName = self.eventName.text
        
        if (eventName == "" || address == "") {
            error = "Please enter an event name and location."
        } else if (count(eventName) < 2 || count(address) < 2) {
            error = "Please enter a valid event name and location."
        }
        
        if (error != "") {
            displayAlert("Event creation error:", error: error)
        } else {
            
            let query = PFUser.query()
            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                
                if error != nil {
                    println(error)
                }
                else
                {
                    
                    var event = PFObject(className: "Event")
                    
                    var geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                        print(placemarks?[0])
                        
                        if let placemark = placemarks?[0] as? CLPlacemark {
                            var location = placemark.location as CLLocation
                            var eventLatitude = location.coordinate.latitude
                            var eventLongitude = location.coordinate.longitude
                            
                            let userGeoPoint = PFGeoPoint(latitude:eventLatitude, longitude:eventLongitude)
                            
                            //event["geoLocation"] = userGeoPoint
                            self.userGeoPoint = userGeoPoint
                        }
                    })
                    
                    print("====================")
                    print(self.userGeoPoint)
                    event["geoLocation"] = self.userGeoPoint
                    
                    //Check if event already exists
                    let query = PFQuery(className: "Event")
                    query.whereKey("eventName", equalTo: eventName)
                    let scoreArray = query.findObjects()
                    
                    if scoreArray!.count == 0 {
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
                        
                        event.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // The object has been saved.
                                //println("**************************success \(event.objectId)")
                                
                                // Subscribe current device to event channel for push notifications
                                //let currentInstallation = PFInstallation.currentInstallation()
                                //currentInstallation.addUniqueObject(("a" + event.objectId!), forKey: "channels")
                                //currentInstallation.saveInBackground()
                            } else {
                                // There was a problem, check error.description
                                println("fail")
                            }
                        }
                        println("---------------GETSHERE--------------")
                        object?.addUniqueObject(event, forKey:"savedEvents")
                        object?.addUniqueObject(eventName, forKey:"savedEventNames")
                        
                        println("---------------GETSHERE2--------------")
                        object!.saveInBackground()
                        println("---------------GETSHERE3--------------")

                        
                        // Add the EventAttendance join table relationship for photos (liked and uploaded)
                        var attendance = PFObject(className:"EventAttendance")
                        println("---------------GETSHERE4--------------")

                        attendance["eventID"] = "test"//event.objectId
                        println("---------------GETSHERE4.5--------------")

                        let temp = "test2"//PFUser.currentUser()?.objectId// as String
                        attendance["attendeeID"] = temp
                        println("---------------GETSHERE5--------------")

                        attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                        
                        println("---------------GETSHERE6--------------")

                        attendance.setObject(event, forKey: "event")
                        println("---------------GETSHERE7--------------")
                        
                        attendance.saveInBackgroundWithBlock{ (success, error) -> Void in
                            if (success) {
                                // The object has been saved.
                                println("suxess")//success \(event.objectId)")
                                
                                // Subscribe current device to event channel for push notifications
                                //let currentInstallation = PFInstallation.currentInstallation()
                                //currentInstallation.addUniqueObject(("a" + event.objectId!), forKey: "channels")
                                //currentInstallation.saveInBackground()
                            } else {
                                // There was a problem, check error.description
                                println("fail")
                                println(error)
                            }

                        }
                        
                        println("Saved")
                        
                    } else {
                        self.displayAlert("This event already exists", error: "Join an existing event below")
                    }
                }
            })
        }
    }
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toEventsPage", sender: self)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //--------------- Draw UI ---------------
        
        // Hide UI controller item
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Nav Bar positioning
        let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.size.width, 64))
        navBar.backgroundColor =  UIColor.whiteColor()
        
        // Removes faint line under nav bar
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        
        // Set the Nav bar properties
        let navBarItem = UINavigationItem()
        navBarItem.title = "Create An Event"
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let logout = UIButton.buttonWithType(.System) as! UIButton
        logout.setBackgroundImage(logoutButton, forState: .Normal)
        logout.frame = CGRectMake(15, 31, 22, 22)
        logout.addTarget(self, action: "settingButton:", forControlEvents: .TouchUpInside)
        navBar.addSubview(logout)
        
        self.view.addSubview(navBar)
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if error == nil {
                print(geoPoint)
                self.userGeoPoint = geoPoint!
            }
            else {
                println("Error with User Geopoint")
            }
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
