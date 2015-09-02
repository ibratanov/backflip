//
//  EventTableViewController.swift
//  BackFlip
//
//  Created by Jack Perry on 2015-08-31.
//  Copyright (c) 2015 BackFlip. All rights reserved.
//

import UIKit
import Parse
import DigitsKit

class EventTableViewController: UITableViewController
{
	
	var events : [Event] = [];
	let CELL_BACKGROUND_COLOR : UIColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
	
	
	//-------------------------------------
	// MARK: View Delegate
	//-------------------------------------
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.tableView.reloadData()
		
		fetchData()
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
	
		self.tableView.userInteractionEnabled = true
		
		if (PFUser.currentUser() == nil) {
			self.performSegueWithIdentifier("display-login-popover", sender: self)
			return
		}
	}
	
	
	//-------------------------------------
	// MARK: Table View Delegate
	//-------------------------------------
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return Int(events.count)
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
	{
		return true
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! EventTableViewCell
		
		let event = self.events[indexPath.row]
		cell.eventName.text = event.name
		cell.eventLocation.text = event.venue
		
		
		if event.photos == nil || event.photos?.count == 0 {
			
			cell.imageOne.image = UIImage()
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.image = UIImage()
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.image = UIImage()
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.image = UIImage()
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count == 1 {
			
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!)!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.image = UIImage()
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.image = UIImage()
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.image = UIImage()
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count == 2 {
			
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!)!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!)!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.image = UIImage()
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.image = UIImage()
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count == 3 {
		
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!)!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!)!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.setImageWithURL(NSURL(string: photos[2].thumbnail!.url!)!)
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.image = UIImage()
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count == 4 {
			
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!)!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!)!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.setImageWithURL(NSURL(string: photos[2].thumbnail!.url!)!)
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.setImageWithURL(NSURL(string: photos[3].thumbnail!.url!)!)
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count == 5 {
		
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!)!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!)!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.setImageWithURL(NSURL(string: photos[2].thumbnail!.url!)!)
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.setImageWithURL(NSURL(string: photos[3].thumbnail!.url!)!)
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.setImageWithURL(NSURL(string: photos[4].thumbnail!.url!)!)
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		}
		
		// Remove the 5th image if the screen is small
		if UIScreen.mainScreen().bounds.size.width <= 320 {
			cell.imageFive.removeFromSuperview()
		}
		
		
		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		
	}
	
	
	
	//-------------------------------------
	// MARK: Segues
	//-------------------------------------
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if segue.identifier == "display-event-album" {
			
			let selectedPath = tableView.indexPathForCell(sender as! UITableViewCell)
			
			let event = self.events[selectedPath!.row]
			let eventViewController = segue.destinationViewController as! EventAlbumViewController
			eventViewController.event = event

		}
	}
	
	
	//-------------------------------------
	// MARK: Data
	//-------------------------------------
	
	func fetchData()
	{
		var _events : [Event] = []
		
		let user = PFUser.currentUser()!.objectId
		let attendances = Attendance.MR_findByAttribute("attendeeId", withValue: user) as! [Attendance]
		for attendance : Attendance in attendances {
			_events.append(attendance.event!)
		}
		
		self.events = _events;
		self.tableView.reloadData()
	}
	
	
	//-------------------------------------
	// MARK: Memory
	//-------------------------------------

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
    }

//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if (editingStyle == UITableViewCellEditingStyle.Delete) {
//            if NetworkAvailable.networkConnection() == true {
//                
//                self.tableView.beginUpdates()
//                // Remove from Parse DB
//                let current = tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
//                let eventObject = eventObjs[indexPath.row]
//                eventDelete(eventObject)
//                
//                // Remove elements from datasource, remove row, reload tableview
//                self.eventObjs.removeAtIndex(indexPath.row)
//                self.eventWithPhotos.removeValueForKey(eventObject.objectId!)
//                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
//                self.tableView.reloadData()
//                self.tableView.endUpdates()
//                
//            } else {
//                displayNoInternetAlert()
//            }
//        }
//        
//
//    }

    
    
    func eventDelete (event : Event ) {
        
//        let eventTitle = event.name
//        let eventID = event.objectId
//
//        if NetworkAvailable.networkConnection() == true {
//           
//            
//            // Set the spinner
//            dispatch_async(dispatch_get_main_queue()) {
//                println(self.view.bounds.width)
//                self.spinner.frame = CGRectMake(self.view.bounds.width/2 - 75, self.view.bounds.height/2 - 75, 150, 150)
//                //self.spinner.center = self.view.center
//                self.spinner.hidden = false
//                self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
//                self.spinner.color = UIColor.blackColor()
//                self.view.addSubview(self.spinner)
//                self.view.bringSubviewToFront(self.spinner)
//                self.spinner.startAnimating()
//                self.tableView.userInteractionEnabled = false
//            }
//            
//
//            // Delete event info from the users DB entry
//            let query = PFUser.query()
//            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
//                object!.removeObject(event, forKey:"savedEvents")
//                object!.removeObject(eventTitle, forKey: "savedEventNames")
//                object!.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//                    if (success) {
//                        
//                        // Re-enable interaction, stop the spinner once parse update is done
//                        self.spinner.stopAnimating()
//                        self.tableView.userInteractionEnabled = true
//                    }
//                }
//            })
//            
//            // Delete event attendence row in Event Attendance class
//            let attendanceQuery = PFQuery(className: "EventAttendance")
//            attendanceQuery.whereKey("attendeeID", equalTo: PFUser.currentUser()!.objectId!)
//            attendanceQuery.whereKey("eventID", equalTo: eventID)
//            attendanceQuery.selectKeys(["photosLiked", "photosLikedID", "flagged", "blocked"])
//            attendanceQuery.limit = 1
//            attendanceQuery.findObjectsInBackgroundWithBlock {
//                (objects: [AnyObject]?, error: NSError?) -> Void in
//                objects?.first?.deleteInBackground()
//            }
//            
//            // Delete user object from event - attendee relation
//            let eventQuery = PFQuery(className: "Event")
//            eventQuery.whereKey("eventName", equalTo: eventTitle)
//            eventQuery.selectKeys(["attendees"])
//            eventQuery.findObjectsInBackgroundWithBlock {
//                (objects: [AnyObject]?, error: NSError?) -> Void in
//                var eventObj = objects?.first as! PFObject
//                let relation = eventObj.relationForKey("attendees")
//                relation.removeObject(PFUser.currentUser()!)
//                eventObj.saveInBackground()
//                
//            }
//        } else {
//            displayNoInternetAlert()
//        }
        
    }
    


}
