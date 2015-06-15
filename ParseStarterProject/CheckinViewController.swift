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
    
    
    var userGeoPoint = PFGeoPoint()
    
    var eventSelected = ""
    
    var userLocation:PFGeoPoint = PFGeoPoint()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if error == nil {
                print(geoPoint)
                self.userGeoPoint = geoPoint!
                print("Get's here")
                
                
            }
            else {
                print("Error with User Geopoint")
            }
        }
*/
        //locationManager.delegate = self
        //locationManager.requestWhenInUseAuthorization()
        //self.pickerInfo.selectRow(2, inComponent: 0, animated: true)

        
        self.calcNearByEvents()
        // Gets location of the user
        /*
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.distanceFilter = 300 //every 300 meters it updates user's location
        locationManager.requestWhenInUseAuthorization() //for testing purposes only
        
        //locationManager.requestAlwaysAuthorization()
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
*/
        
        //self.pickerInfo.reloadAllComponents()
    
    }
    
    func calcNearByEvents() {

        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if error == nil {
                print(geoPoint)
                self.userGeoPoint = geoPoint!
                print("successfully retrieved User GeoPoint")
                // Queries events table for locations that are close to user
                // Return top 3 closest events
                var query = PFQuery(className: "Event")
                //query.whereKey("geoLocation", nearGeoPoint:userGeoPoint)
                query.whereKey("geoLocation", nearGeoPoint: self.userGeoPoint, withinKilometers: 10.0)
                query.limit = 5
                let placesObjects = query.findObjects() as! [PFObject]
                
                print(placesObjects.count)
                
                for object in placesObjects {
                    var eventName: AnyObject? = object.objectForKey("eventName")
                    
                    // hack, fix later
                    if self.cellContent.count < query.limit {
                        self.cellContent.addObject(eventName!)
                    }
                    
                }
                
            }
            else {
                print("Error with User Geopoint")
            }
            
            self.pickerInfo.reloadAllComponents()

        }
        
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
        //self.pickerInfo.reloadAllComponents()
        //locationManager.stopUpdatingLocation()
        
        //self.pickerInfo.reloadAllComponents()
        
        if (self.cellContent.count > 0) {
            self.eventSelected = self.cellContent[0] as! String//self.cellContent[(cellContent.count/2)] as! String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var checkInButton: UIButton!
    
    @IBAction func checkInClicked(sender: AnyObject) {
        
        // Add user to this event
        var eventName = self.eventSelected
        println("\n\nchecking in to " + eventSelected)
        
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
                query.whereKey("eventName", equalTo: self.eventSelected)
                let scoreArray = query.findObjects()
                
                if scoreArray!.count == 0 {
                    
                    self.displayAlert("No Nearby Events", error: "Please create a new event")
//                    let event = PFObject(className: "Event")
//                    event["eventName"] = self.eventSelected
//                    event["startTime"] = NSDate()
//                    event["isLive"] = true
//                    
//                    let relation = event.relationForKey("observers")
//                    relation.addObject(object!)
//                
//                    event.saveInBackgroundWithBlock {
//                        (success: Bool, error: NSError?) -> Void in
//                        if (success) {
//                            // The object has been saved.
//                            println("\n=================\nsuccess \(event.objectId)")
//                        } else {
//                            // There was a problem, check error.description
//                            println("\n=================\nfail")
//                        }
//                    }
                }
                else {
                    
                }
                    
                // TODO: Check for existing event_list for eventName
                var listEvents = object!.objectForKey("savedEvents") as! [String]
                if contains(listEvents, self.eventSelected)
                {
                    print("Event already in list")
                }
                else
                {
                    object?.addUniqueObject(self.eventSelected, forKey:"savedEvents")
                
                    //let eventList = object?.objectForKey("savedEvents") as! [String]
                
                    object!.saveInBackground()
                    
                    
                    // Add the EventAttendance join table relationship for photos (liked and uploaded)
                    var attendance = PFObject(className:"EventAttendance")
//                        attendance["eventID"] = event.objectId
                    attendance["attendeeID"] = PFUser.currentUser()?.objectId
                    attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
//                        attendance.setObject(event, forKey: "event")
                    
                    attendance.saveInBackground()
                    
                    println("Saved")
                }
            }
        })
    }
    
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("whereAreYouToEvents", sender: self)
    }
    
    /*
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
        print("Gets here===============")
        print(placesObjects.count)
        dump(placesObjects)
        
        if (placesObjects.count == 0) {
            pickerInfo.hidden = true
        } else {
        
            for object in placesObjects {
                var eventName: AnyObject? = object.objectForKey("eventName")
                
                // hack, fix later
                if cellContent.count < query.limit {
                    cellContent.addObject(eventName!)
                }

            }
            
            self.pickerInfo.selectRow(0, inComponent: 0, animated: true)
            self.eventSelected = self.cellContent[0] as! String
            
        }
        
        self.pickerInfo.reloadAllComponents()

    }
*/
    
    // Two functions to allow off keyboard touch to close keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

// TEMP WORK ON SCROLLABLE PICKERVIEW - http://codereply.com/answer/8crh93/uipickerview-loop-data.html
//    func valueForRow(row: Int) -> String {
//        //the rows repeat every cellContent.count items
//        return "test" //self.cellContent[row % self.cellContent.count] as! String
//    }
//    
//    func rowForValue(value: Int) -> Int? {
//        //if let valueIndex: AnyObject = self.cellContent[value] {
//            return 2 + value
//        //}
//        //return nil
//    }
//    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
//        return valueForRow(row)//"\(valueForRow(row))"
//    }
//    
//    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 20
//    }
//    
//    // whenever the picker view comes to rest, we'll jump back to
//    // the row with the current value that is closest to the middle
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let newRow = 2 + (row % self.cellContent.count)
//        pickerView.selectRow(newRow, inComponent: 0, animated: false)
//        println("Resetting row to \(newRow)")
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
