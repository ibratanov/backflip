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

class CreatePublicEventViewController: UIViewController {
    
    
    @IBAction func settingButton(sender: AnyObject) {
        displayAlert("Would you like to log out?", error: "")
    }
    
    var userGeoPoint = PFGeoPoint()
    
    // Disable navigation
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    var address2:String = ""
    
    @IBOutlet var eventName: UITextField!
    
    @IBOutlet var userAddressButton: UIButton!
    
    @IBOutlet var addressField: UITextField!
    
    /*
    func displayAlert(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
*/
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        // Facebook share feature
        alert.addAction(UIAlertAction(title: "Logout", style: .Default, handler: { action in
            
            
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
            event["geoLocation"] = userGeoPoint
            //Check if event already exists
            let query = PFQuery(className: "Event")
            query.whereKey("eventName", equalTo: eventName)
            let scoreArray = query.findObjects()
            
            if scoreArray!.count == 0 {
                event["eventName"] = eventName
                event["venue"] = address
                event["startTime"] = NSDate()
                event["isLive"] = true
                
                // Store the relation
                let relation = event.relationForKey("observers")
                relation.addObject(PFUser.currentUser()!)//object!)
                
                event.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        println("success \(event.objectId)")
                    } else {
                        // There was a problem, check error.description
                        println("fail")
                    }
                }
                
            } else {
                println("event exists")
            }
            
        }
    }
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toEventsPage", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
