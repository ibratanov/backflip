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

class EventViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableInfo: UITableView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var locationManager = CLLocationManager()
    
    var cellContent:NSMutableArray = []
    
    func displayAlert(title:String,error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            //set to false, to prevent login screen flashes on failed login attempt
            self.dismissViewControllerAnimated(false, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    @IBAction func clearTable(sender: AnyObject) {
        
        cellContent.removeAllObjects()
        //tableInfo.reloadData()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        /*
        PFGeoPoint.geoPoint {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                var userLatitude = geoPoint!.latitude //latitude of user who creates event
                var userLongitude = geoPoint!.longitude //longitude of user who creates event
                
                var event = PFObject(className: "Events") //creates table of Events
                
                let point = PFGeoPoint(latitude: userLatitude, longitude: userLongitude)
                
                println(point)
                
                var query = PFQuery(className: "Events")
                query.whereKey("geoLocation", nearGeoPoint: point)
                query.limit = 3
                let placesObjects = query.findObjects() as! [PFObject]
                
                //dump(placesObjects)
                
                for object in placesObjects {
                    var eventName = object.objectForKey("eventName")
                    //println(eventName)
                    
                    // hack, fix later
                    if cells2.count < query.limit {
                        cells2.addObject(eventName!)
                        //println("Get's here")
                    }
                    dump(cells2)
                    
                }
            }
            
            
        }
*/
        
        
        self.tableInfo.reloadData()
        
        activityIndicator.stopAnimating()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets location of the user
        locationManager.delegate = self
        
        // locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //locationManager.distanceFilter = 300 //every 300 meters it updates user's location
        locationManager.requestWhenInUseAuthorization() //for testing purposes only
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view.
    }
    
    // Allows us to return an integer that will be the number sections in the table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellContent.count
        
    }
    
    // Define contents of each individual cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")

        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        cell?.layer.cornerRadius = 5.0
        
        if !(cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")}
        
        cell!.textLabel?.text = cellContent[indexPath.row] as! String
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        eventField.text = selectedCell.textLabel?.text
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            cellContent.removeObjectAtIndex(indexPath.row)
            tableInfo.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        self.tableInfo.reloadData()
        self.tableInfo.separatorStyle = UITableViewCellSeparatorStyle.None
        
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
        
        if (eventField.text == "") {
            
            error = "Please enter an event name."
            
        }
        
        if (count(eventField.text) < 2)  {
            
            error = "Please enter a valid event name."
        }
        
        if (error != "") {
            
            displayAlert("Event creation error:", error: error)
            
        } else {
        
            var event = PFObject(className:"Events")
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
            
        }
    }
    @IBAction func pastEventsButton(sender: AnyObject) {
        self.performSegueWithIdentifier("whereAreYouToEvents", sender: self)
        
    
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
        var query = PFQuery(className: "Events")
        query.whereKey("geoLocation", nearGeoPoint:userGeoPoint)
        query.limit = 3
        let placesObjects = query.findObjects() as! [PFObject]
        
        for object in placesObjects {
            var eventName = object.objectForKey("eventName")
            
            // hack, fix later
            if cellContent.count < query.limit {
                cellContent.addObject(eventName!)
            }
           
        }
        //dump(cellContent)
        

        /*
        for result in placesObjects {
            var description = result.objectForKey("eventName") as! NSString
            cellContent.append(description)
        }
        */
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
