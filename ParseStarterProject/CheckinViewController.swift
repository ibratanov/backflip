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

class CheckinViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var userLocation:PFGeoPoint = PFGeoPoint()
    
    @IBOutlet var pickerInfo: UIPickerView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var locationManager = CLLocationManager()
    
    var cellContent:NSMutableArray = []
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            // Commented out below, causes flashing view when display is dismissed
            //self.dismissViewControllerAnimated(false, completion: nil)
            
        }))
        
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
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        eventField.text = self.cellContent[row] as! String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets location of the user
        locationManager.delegate = self
        
        // locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.distanceFilter = 300 //every 300 meters it updates user's location
        locationManager.requestWhenInUseAuthorization() //for testing purposes only
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        print("Get's here")
    
    }
    
    override func viewDidAppear(animated: Bool) {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        self.pickerInfo.reloadAllComponents()
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var eventField: UITextField!

    @IBOutlet weak var checkInButton: UIButton!
    @IBAction func checkInClicked(sender: AnyObject) {
        
        var error = ""
        print("Get's here")
        if (eventField.text == "") {
            
            error = "Please enter an event name."
            
        } else if (count(eventField.text) < 2)  {
            
            error = "Please enter a valid event name."
        }
        
        if (error != "") {
            
            displayAlert("Event creation error:", error: error)
            
        } else {
            var event = PFObject(className:"Event")
            event["eventName"] = eventField.text
            //event["startTime"] =
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
            
            let query = PFUser.query()
            
            println(PFUser.currentUser()!.objectId!)
            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                
                if error != nil {
                    println(error)
                }
                else
                {
                    
                    //Check if event already exists
                    let query = PFQuery(className: "Event")
                    query.whereKey("eventName", equalTo: self.eventField.text)
                    let scoreArray = query.findObjects()
                    
                    if scoreArray!.count == 0 {
                        let eventRel = PFObject(className: "Event")
                        eventRel["eventName"] = self.eventField.text
                        let relation = eventRel.relationForKey("observers")
                        relation.addObject(object!)
                    
                        eventRel.saveInBackground()
                    }
                    else {
                        
                    }
                        
                    // TODO: Check for existing event_list for eventName
                    var listEvents = object!.objectForKey("savedEvents") as! [String]
                    if contains(listEvents,self.eventField.text)
                    {
                        print("Event already in list")
                    }
                    else
                    {
                        object?.addUniqueObject(self.eventField.text!, forKey:"savedEvents")
                    
                        //let eventList = object?.objectForKey("savedEvents") as! [String]
                    
                        object!.saveInBackground()
                    
                        
                    
                        println("Saved")
                    }
                }
            })
            
            
        }
    }
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("whereAreYouToEvents", sender: self)
    }
    
    // Two functions to allow off keyboard touch to close keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // This is a listener that constantly checks if the user's location is close to an event
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // location of the user
        var userLocation:CLLocation = locations[0] as! CLLocation
        
        // latitude and longitude of user
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        
        // sets parse geopoint
        let userGeoPoint = PFGeoPoint(latitude:latitude, longitude:longitude)
        
        // Queries events table for locations that are close to user
        // Return top 3 closest events
        var query = PFQuery(className: "Event")
        //query.whereKey("geoLocation", nearGeoPoint:userGeoPoint)
        query.whereKey("geoLocation", nearGeoPoint: userGeoPoint, withinKilometers: 10.0)
        query.limit = 5
        let placesObjects = query.findObjects() as! [PFObject]
        
        //print(placesObjects.count)
        dump(placesObjects)
        
        for object in placesObjects {
            var eventName = object.objectForKey("eventName")
            
            // hack, fix later
            if cellContent.count < query.limit {
                cellContent.addObject(eventName!)
            }
           
        }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    }
}
