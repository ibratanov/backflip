//
//  EventViewController.swift
//  ParseStarterProject
//
//  Created by Zachary Lefevre on 2015-05-19.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import DigitsKit

class CheckinViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var noEventLabel: UILabel!
    
    @IBAction func logoutButton(sender: AnyObject) {
        displayAlertLogout("Would you like to log out?", error: "")
        
    }
    
    var logoutButton = UIImage(named: "settings-icon") as UIImage!

    var userGeoPoint = PFGeoPoint()
    
    var eventSelected = ""
    
    var userLocation:PFGeoPoint = PFGeoPoint()
    
    var locationDisabled = false
    
    @IBOutlet var pickerInfo: UIPickerView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var locationManager = CLLocationManager()
    
    var cellContent:NSMutableArray = []
    
    func displayAlert(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Scroll wheel table view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.cellContent.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.cellContent[row] as! String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(self.cellContent[row])
        eventSelected = self.cellContent[row] as! String
    }
    
    
    func displayAlertLogout(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Facebook share feature
        alert.addAction(UIAlertAction(title: "Log Out", style: .Default, handler: { action in
            
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            self.performSegueWithIdentifier("logoutCheckIn", sender: self)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
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
        navBarItem.title = "Nearby Events"
        navBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "Avenir-Medium",size: 18)!]
        navBar.items = [navBarItem]
        
        // Left nav bar button item
        let logout = UIButton.buttonWithType(.System) as! UIButton
            logout.setImage(logoutButton, forState: .Normal)
            logout.tintColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
            logout.frame = CGRectMake(-10, 20, 72, 44)
            logout.addTarget(self, action: "logoutButton:", forControlEvents: .TouchUpInside)
        navBar.addSubview(logout)

        self.view.addSubview(navBar)
        
        if NetworkAvailable.networkConnection() == true {
            
            let query = PFUser.query()
            var userObjectId = PFUser.currentUser()?.objectId!
            query!.getObjectInBackgroundWithId(userObjectId!, block: { (object, error) -> Void in

                var firstTime = PFUser.currentUser()?.objectForKey("firstUse") as! Bool
                
                if (firstTime == true) {

                    
                    if error != nil {
                        println(error)
                    }
                    else
                    {
                        
                        //Check if event exists
                        let query = PFQuery(className: "Event")
                        query.whereKey("eventName", equalTo: "Welcome to Backflip")
                        let scoreArray = query.findObjects()
                        
                        
                        var event = scoreArray?[0] as! PFObject
                        
                        
                        // Store the relation
                        let relation = event.relationForKey("attendees")
                        relation.addObject(object!)
                        
                        event.save()
                        
                        // Add the event to the User object
                        object?.addUniqueObject(event, forKey:"savedEvents")
                        object?.addUniqueObject("Welcome to BackFlip", forKey:"savedEventNames")
                        
                        object!.saveInBackground()
                        
                        
                        // Add the EventAttendance join table relationship for photos (liked and uploaded)
                        var attendance = PFObject(className:"EventAttendance")
                        attendance["eventID"] = event.objectId
                        attendance["attendeeID"] = PFUser.currentUser()?.objectId
                        attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                        attendance.setObject(event, forKey: "event")
                        attendance["photosLikedID"] = []
                        attendance["photosLiked"] = []
                        attendance["photosUploaded"] = []
                        attendance["photosUploadedID"] = []
                        
                        
                        attendance.saveInBackground()
                        PFUser.currentUser()?.setObject(false, forKey: "firstUse")
            
                        
                    }
                }
                
            })
                
            self.calcNearByEvents()
        } else {
            
            var alert = NetworkAvailable.networkAlert("Error", error: "No internet")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")

        }
    }
    
    func calcNearByEvents() {
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if error == nil {
                print(geoPoint)
                self.userGeoPoint = geoPoint!
                print("successfully retrieved User GeoPoint")
                
                // Set default event radius
                var eventRadius = 5.0
                var distQuery = PFQuery(className: "Options")
                var distance = distQuery.findObjects()
                var result = distance?.first as! PFObject
                eventRadius = result["value"] as! Double
                
                // Queries events table for locations that are close to user
                // Return top 5 closest events
                var query = PFQuery(className: "Event")
                //query.whereKey("geoLocation", nearGeoPoint:userGeoPoint)
                query.whereKey("geoLocation", nearGeoPoint: self.userGeoPoint, withinKilometers: eventRadius)
                query.limit = 10

                var usr = PFQuery.getUserObjectWithId(PFUser.currentUser()!.objectId!)
                var savedEvents: [String] = usr!.objectForKey("savedEventNames") as! [String]
                
                var objects = query.findObjects()
                for object in objects as! [PFObject] {
                    var eventName = object.objectForKey("eventName") as! String
                    var active = object.objectForKey("isLive") as! Bool
                    
                    // TODO: Check
                    if active && self.cellContent.count < query.limit && !contains(savedEvents, eventName) {
                        self.cellContent.addObject(eventName)
                    }
                    
                }
                
                if self.cellContent.count == 0 {
                    self.pickerInfo.hidden = true
                    self.noEventLabel.text = "No Events Nearby"
                }
                else {
                    self.pickerInfo.reloadAllComponents()
                }
                
            }
            else {
                print("Error with User Geopoint")
                println(error)
                
                self.locationDisabled = true
                self.pickerInfo.hidden = true
                self.noEventLabel.text = "No Events Nearby"
            }
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        //self.pickerInfo.reloadAllComponents()
        //locationManager.stopUpdatingLocation()

        if NetworkAvailable.networkConnection() == true {
            if (self.cellContent.count > 0) {
                self.eventSelected = self.cellContent[0] as! String
            }
        } else {
            var alert = NetworkAvailable.networkAlert("Error", error: "No internet")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var checkInButton: UIButton!
    
    @IBAction func checkInClicked(sender: AnyObject) {
        
        if NetworkAvailable.networkConnection() == true {
            if (self.eventSelected == "" && self.cellContent.count > 0) {
                self.eventSelected = self.cellContent[0] as! String
            }
            
            // Add user to this event
            var eventName = self.eventSelected

            println("\n\nchecking in to " + self.eventSelected)
            
            let query = PFUser.query()
            
            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                
                if error != nil {
                    println(error)
                }
                else
                {
                    
                    //Check if event exists
                    let query = PFQuery(className: "Event")
                    query.whereKey("eventName", equalTo: self.eventSelected)
                    let scoreArray = query.findObjects()
                    if self.locationDisabled == true {
                        self.displayAlert("No Nearby Events", error: "Please enable location access in the iOS settings for Backflip.")
                    } else if scoreArray!.count == 0 {
                        self.displayAlert("No Nearby Events", error: "Create a new event!")
                    }
                    else {
                        var event = scoreArray?[0] as! PFObject

                        // Subscribe user to the channel of the event for push notifications
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation.addUniqueObject(("a" + event.objectId!) , forKey: "channels")
                        currentInstallation.saveInBackground()
                        
                        // Store the relation
                        let relation = event.relationForKey("attendees")
                        relation.addObject(object!)
                        
                        event.save()
                        
                        var listEvents = object!.objectForKey("savedEventNames") as! [String]
                        if contains(listEvents, self.eventSelected)
                        {
                            print("Event already in list")
                            self.performSegueWithIdentifier("whereAreYouToEvents", sender: self)
                        }
                        else
                        {
                            // Add the event to the User object
                            object?.addUniqueObject(event, forKey:"savedEvents")
                            object?.addUniqueObject(self.eventSelected, forKey:"savedEventNames")
                            
                            object!.saveInBackground()
                            
                            
                            // Add the EventAttendance join table relationship for photos (liked and uploaded)
                            var attendance = PFObject(className:"EventAttendance")
                            attendance["eventID"] = event.objectId
                            attendance["attendeeID"] = PFUser.currentUser()?.objectId
                            attendance["photosLikedID"] = []
                            attendance["photosLiked"] = []
                            attendance["photosUploadedID"] = []
                            attendance["photosUploaded"] = []
                            attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                            attendance.setObject(event, forKey: "event")
                            
                            attendance.saveInBackground()
                            
                            println("Saved")
                            self.performSegueWithIdentifier("whereAreYouToEvents", sender: self)
                        }
                    }
                }
            })
        } else {
            
            var alert = NetworkAvailable.networkAlert("Error", error: "No internet")
            self.presentViewController(alert, animated: true, completion: nil)
            println("no internet")

            
        }
            
    
    }
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("whereAreYouToEvents", sender: self)
    }
    
    // Two functions to allow off keyboard touch to close keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

}
