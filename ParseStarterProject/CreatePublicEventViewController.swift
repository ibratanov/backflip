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
    
    var userGeoPoint = PFGeoPoint()
    
    @IBOutlet var eventName: UITextField!
    
    
    @IBOutlet var userAddressButton: UIButton!
    
    @IBOutlet var addressField: UITextField!
    
    
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
            self.addressField.text = address
            
            
        })
        
        self.userAddressButton.hidden = true
        
        var event = PFObject(className:"Event")
        event["eventName"] = self.eventName.text
        
        let userGeoPoint = PFGeoPoint(latitude:userLatitude, longitude:userLongitude)
        event["geoLocation"] = userGeoPoint
        
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
        
        
        
    }

    
    //Add event to event class
    @IBAction func createEvent(sender: AnyObject) {
        
        var address = self.addressField.text
        
        var eventName = self.eventName.text
        
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            //print(placemarks?[0])
            
            if let placemark = placemarks?[0] as? CLPlacemark {
                var location = placemark.location as CLLocation
                var eventLatitude = location.coordinate.latitude
                var eventLongitude = location.coordinate.longitude
                
                //Create Event
                var event = PFObject(className:"Event")
                event["eventName"] = eventName
                
                let userGeoPoint = PFGeoPoint(latitude:eventLatitude, longitude:eventLongitude)
                event["geoLocation"] = userGeoPoint
                
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
                
                
            }
            
        })
        
        self.performSegueWithIdentifier("eventsPage", sender: self)
    }
    
    
    @IBAction func pastEvents(sender: AnyObject) {
        self.performSegueWithIdentifier("pastEventsTrans", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if error == nil {
                print(geoPoint)
                self.userGeoPoint = geoPoint!
            }
            else {
                print("Error with User Geopoint")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
