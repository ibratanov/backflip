//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Zachary Lefevre on 2015-05-11.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import DigitsKit

class EventTableViewController: UITableViewController {
    
    @IBAction func logoutButton(sender: AnyObject) {
        displayAlertLogout("Would you like to log out?", error: "")
    }
    
    func addEvent(sender: AnyObject) {
        performSegueWithIdentifier("addEventSegue", sender: nil)
    }
    
    var eventWithPhotos = [String:[PFFile]]()
    var eventObjs: [PFObject] = []

    var logoutButton = UIImage(named: "settings-icon") as UIImage!
    var addButton = UIImage(named: "add-icon") as UIImage!
    
    let qos = (Int(QOS_CLASS_BACKGROUND.value))
    
//    Enable UI Navigation Item
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir-Medium",size: 18)!]
        self.tableView.reloadData()
        
        if NetworkAvailable.networkConnection() == true {
            
            updateEvents()
            
        } else {
            displayNoInternetAlert()
        }
    }
    
    override func viewDidLoad() {
        
        //updateEvents()

        
    }
    
    func displayAlertLogout(title:String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { action in
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
            
            PFUser.logOut()
            Digits.sharedInstance().logOut()
            
            self.performSegueWithIdentifier("logoutEventView", sender: self)
            
        }))
		
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayNoInternetAlert() {
        var alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to log in.")
        self.presentViewController(alert, animated: true, completion: nil)
        println("no internet")
    }
    
    func updateEvents(){

        if NetworkAvailable.networkConnection() == true {
            let query = PFUser.query()
            query?.includeKey("savedEvents")
            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                if (error == nil) {
                    self.eventObjs.removeAll(keepCapacity: true)

                    self.eventObjs = object!.objectForKey("savedEvents") as! [PFObject]
                    
                    self.eventObjs = sorted(self.eventObjs, { $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending })
                    
                    // Dispatch queries to background queue
                    dispatch_async(dispatch_get_global_queue(self.qos, 0)) {
                        println("HERE")
                        for event in self.eventObjs {
                            let relation = event.relationForKey("photos")
                            let query = relation.query()
                            query!.whereKey("flagged", equalTo: false)
                            query!.whereKey("blocked", equalTo: false)
                            query!.limit = 4
                            
                            var photos = query!.findObjects()
                            
                            // Return to main queue for UI updates
                            
                                if (photos != nil && photos!.count != 0) {
                                    var thumbnails: [PFFile] = []
                                 
                              
                                    for photo in photos! {
                                        thumbnails.append(photo["thumbnail"] as! PFFile)
                                    }
                                        //self.eventWithPhotos.removeAll(keepCapacity: true)
                                        self.eventWithPhotos[event.objectId!] = thumbnails

                                    }
                                
                                else {
                                  
                                        //self.eventWithPhotos.removeAll(keepCapacity: true)
                                        var thumbnails: [PFFile] = []
                                        self.eventWithPhotos[event.objectId!] = thumbnails
                                    
                                }
                            dispatch_async(dispatch_get_main_queue()) {
                                println("PHOTOS COUNT")
                                println(self.eventWithPhotos.count)
                                println("OBJS COUNT")
                                println(self.eventObjs.count)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                else {
                    println(error)
                }
            })
        } else {
            self.displayNoInternetAlert()
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }

    // Table View delegate methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.eventObjs.count
        return self.eventWithPhotos.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! EventTableViewCell
        tableCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        var ev : PFObject = eventObjs[indexPath.row]
        var evName : String = ev["eventName"] as! String
        var evVenue : String = ev["venue"] as! String
        
        var listPhotos = self.eventWithPhotos[ev.objectId!] as [PFFile]!
        var underlineColor : UIColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
        
        tableCell.eventName.text = evName
        tableCell.eventLocation.text = evVenue
        
        if listPhotos.count == 0 {
            tableCell.imageOne!.image = UIImage ()
            tableCell.imageOne.backgroundColor = underlineColor
            
            tableCell.imageTwo!.image = UIImage ()
            tableCell.imageTwo.backgroundColor = underlineColor
            
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageThree.backgroundColor = underlineColor
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor

            return tableCell
        }
        
        if listPhotos.count == 1 {
            var imageData1 = listPhotos[0]
            tableCell.imageOne!.file = imageData1
            
            tableCell.imageTwo!.image = UIImage ()
            tableCell.imageTwo.backgroundColor = underlineColor
            
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageThree.backgroundColor = underlineColor
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor
            
            tableCell.imageOne.loadInBackground()

            return tableCell
        }
        
        if listPhotos.count == 2 {
            var imageData1 = listPhotos[0]
            tableCell.imageOne!.file = imageData1
            
            var imageData2 = listPhotos[1]
            tableCell.imageTwo!.file = imageData2
            
            tableCell.imageThree!.image = UIImage ()
            tableCell.imageThree.backgroundColor = underlineColor
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor
            
            tableCell.imageOne.loadInBackground()
            tableCell.imageTwo.loadInBackground()

            
            return tableCell
        }
        
        if listPhotos.count == 3 {
            var imageData1 = listPhotos[0]
            tableCell.imageOne!.file = imageData1
            
            var imageData2 = listPhotos[1]
            tableCell.imageTwo!.file = imageData2
            
            var imageData3 = listPhotos[2]
            tableCell.imageThree!.file = imageData3
            
            tableCell.imageFour!.image = UIImage ()
            tableCell.imageFour.backgroundColor = underlineColor
            
            tableCell.imageOne.loadInBackground()
            tableCell.imageTwo.loadInBackground()
            tableCell.imageThree.loadInBackground()

            
            return tableCell
        }
        
        if listPhotos.count >= 4 {
            var imageData1 = listPhotos[0]
            tableCell.imageOne!.file = imageData1
            
            var imageData2 = listPhotos[1]
            tableCell.imageTwo!.file = imageData2
            
            var imageData3 = listPhotos[2]
            tableCell.imageThree!.file = imageData3
            
            var imageData4 = listPhotos[3]
            tableCell.imageFour!.file = imageData4
            
            tableCell.imageOne.loadInBackground()
            tableCell.imageTwo.loadInBackground()
            tableCell.imageThree.loadInBackground()
            tableCell.imageFour.loadInBackground()

            return tableCell
        }
        
        return tableCell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            //self.tableView.beginUpdates()
            let current = tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
            dump(eventObjs)
            let eventObject = eventObjs[indexPath.row]
            eventDelete(eventObject)
            self.eventObjs.removeAtIndex(indexPath.row)
            self.eventWithPhotos.removeValueForKey(eventObject.objectId!)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }

    }
    
    
    func eventDelete (event : PFObject ) {
        
        let eventTitle = event["eventName"] as! String
        let eventID = event.objectId! as String
        
        if NetworkAvailable.networkConnection() == true {
            // Delete event info from the users DB entry
            let query = PFUser.query()
            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                object!.removeObject(event, forKey:"savedEvents")
                object!.removeObject(eventTitle, forKey: "savedEventNames")
                object!.saveInBackground()
            })
            
            // Delete event attendence row in Event Attendance class
            let attendanceQuery = PFQuery(className: "EventAttendance")
            attendanceQuery.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
            attendanceQuery.whereKey("eventID", equalTo: eventID)
            attendanceQuery.selectKeys(["photosLiked", "photosLikedID", "flagged", "blocked"])
            attendanceQuery.limit = 1
            attendanceQuery.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                objects?.first?.deleteInBackground()
            }
        } else {
            displayNoInternetAlert()
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toAlbum" {
            
            let moveVC = segue.destinationViewController as! AlbumViewController
            
            if let selectedPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                var event = eventObjs[selectedPath.row]
                moveVC.eventId = event.objectId
                moveVC.eventTitle = event["eventName"] as? String
            }
        }
    }

}
