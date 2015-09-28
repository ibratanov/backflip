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
import MapleBacon

class EventTableViewController: UITableViewController, UIViewControllerTransitioningDelegate
{
	
	var events : [Event] = [];
	private let animationController = DAExpandAnimation()
	let CELL_BACKGROUND_COLOR : UIColor = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
	
	
	//-------------------------------------
	// MARK: View Delegate
	//-------------------------------------
	
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView()
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.tableView.reloadData()
		MapleBaconStorage.sharedStorage.clearMemoryStorage()
		
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
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
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
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.image = UIImage()
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.image = UIImage()
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count == 3 {
		
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.setImageWithURL(NSURL(string: photos[2].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.image = UIImage()
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count == 4 {
			
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.setImageWithURL(NSURL(string: photos[2].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.setImageWithURL(NSURL(string: photos[3].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.image = UIImage()
			cell.imageFive.backgroundColor = CELL_BACKGROUND_COLOR
			
		} else if event.photos?.count >= 5 {
		
			let photos : [Photo] = event.photos?.allObjects as! [Photo]
			cell.imageOne.setImageWithURL(NSURL(string: photos[0].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageOne.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageTwo.setImageWithURL(NSURL(string: photos[1].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageTwo.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageThree.setImageWithURL(NSURL(string: photos[2].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageThree.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFour.setImageWithURL(NSURL(string: photos[3].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
			cell.imageFour.backgroundColor = CELL_BACKGROUND_COLOR
			
			cell.imageFive.setImageWithURL(NSURL(string: photos[4].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
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
		MapleBaconStorage.sharedStorage.clearMemoryStorage()
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
	{
		if (editingStyle == .Delete) {
			
			// Check network status
			if (NetworkAvailable.networkConnection() == true) {
				
				self.tableView.beginUpdates()
				
				let event = self.events[indexPath.row]
				self.events.removeAtIndex(indexPath.row)
				
				// Here, we need to update coredata and save to parse..
				disableAttendance(event)
				
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
				
				self.tableView.endUpdates()
			}
			
		}
	}
	
	
	
	//-------------------------------------
	// MARK: Segues
	//-------------------------------------
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if segue.identifier == "display-event-album" {
						
			let selectedPath = tableView.indexPathForCell(sender as! UITableViewCell)
			let selectedCell = sender as! UITableViewCell
			
			let event = self.events[selectedPath!.row]
			let eventViewController = segue.destinationViewController as! EventAlbumViewController
			eventViewController.event = event
			eventViewController.transitioningDelegate = self
			eventViewController.modalPresentationStyle = .Custom
			animationController.animationDuration = 2.0
			animationController.collapsedViewFrame = {
				selectedCell.frame
			}
			
			tableView.deselectRowAtIndexPath(selectedPath!, animated: false)
		}
	}


	//-------------------------------------
	// MARK: Animations
	//-------------------------------------
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{
		return animationController
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{
		return animationController
	}
	
	
	
	//-------------------------------------
	// MARK: Data
	//-------------------------------------
	
	func fetchData()
	{
		var _events : [Event] = []
		
		let currentEventId : String? = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id") as? String
		let user = PFUser.currentUser()!.objectId
		let attendances = Attendance.MR_findByAttribute("attendeeId", withValue: user) as! [Attendance]
		for attendance : Attendance in attendances {
			if (currentEventId == attendance.event?.objectId) {
				continue
			} else if (attendance.enabled != nil && Bool(attendance.enabled!) == true) {
				_events.append(attendance.event!)
			}
		}
		
		
		// Sort events
		_events.sortInPlace{ $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending }
		
		self.events = _events;
		self.tableView.reloadData()
	}
	
	func disableAttendance(event : Event)
	{
		var object : Attendance? = nil
		let attendances = Attendance.MR_findByAttribute("attendeeId", withValue: PFUser.currentUser()!.objectId) as! [Attendance]
		for attendance : Attendance in attendances {
			if (attendance.event != nil && attendance.event!.objectId! == event.objectId!) {
				object = attendance
				break
			}
		}
		
		if (object != nil && object!.objectId != nil) {
			
			// Save to CoreData
			let context = NSManagedObjectContext.MR_defaultContext()
			context.saveWithBlock({ (_context) -> Void in
				
				let _object = Attendance.MR_findFirstByAttribute("objectId", withValue: object!.objectId!)
				_object.enabled = NSNumber(bool: false)
				
			}, completion:nil)
		
			
			// Save to Parse
			let attendance = PFObject(withoutDataWithClassName: "EventAttendance", objectId: object!.objectId)
			attendance["enabled"] = false
			
			attendance.saveInBackground()
			
		}
		
	}
	
	
	
	//-------------------------------------
	// MARK: Memory
	//-------------------------------------

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
		
		MapleBaconStorage.sharedStorage.clearMemoryStorage()
    }
	
    

}
