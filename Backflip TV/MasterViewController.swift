//
//  MasterViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-20.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import Foundation


class MasterViewController : UITableViewController
{
	
	
	var eventObjects : [PFObject] = []
	
	
	
	override func loadView()
	{
		super.loadView()
		
		fetchData()
	}
	
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.eventObjects.count
	}
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier("cell-identifier", forIndexPath: indexPath)
		
		let object = self.eventObjects[indexPath.row]
		cell.textLabel?.text = object["eventName"] as! String
		
		return cell
	}
	
	
	
	
	func fetchData()
	{
		
		let attendanceQuery = PFQuery(className: "EventAttendance")
		attendanceQuery.whereKey("attendeeID", equalTo: "5PBeFb6CKX")
		attendanceQuery.includeKey("event")
		attendanceQuery.findObjectsInBackgroundWithBlock { (attendances, error) -> Void in
			
			print("We have \(attendances?.count) results..")
			
			self.eventObjects.removeAll()
			for attendance in attendances! {
				self.eventObjects.append((attendance["event"] as! PFObject))
			}
			
			self.tableView.reloadData()
		}
		
		
//		let query = PFUser.query()
//		query?.includeKey("savedEvents")
//		query!.getObjectInBackgroundWithId("5PBeFb6CKX", block: { (object, error) -> Void in
//			if (error == nil) {
//				self.eventObjects.removeAll()
//				
//				self.eventObjects = object!.objectForKey("savedEvents") as! [PFObject]
//				
//				let currentEventId = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id") as? String
//				if (currentEventId != nil) {
//					for event in self.eventObjects {
//						if (event.objectId == currentEventId) {
//							self.eventObjects.removeAtIndex(self.eventObjects.indexOf(event)!)
//						}
//					}
//				}
//				
//				
//				// self.eventObjects = sorted(self.eventObjects, { $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending })
//				
//				// Dispatch queries to background queue
//				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//					print("HERE")
//					for event in self.eventObjects {
//						let relation = event.relationForKey("photos")
//						let query = relation.query()
//						query!.whereKey("flagged", equalTo: false)
//						query!.whereKey("blocked", equalTo: false)
//						query!.limit = 5
//						
//						query?.findObjectsInBackgroundWithBlock({ (photos, error) -> Void in
//							
//							var thumbnails: [PFFile] = []
//							
//							// Return to main queue for UI updates
//							if (photos != nil && photos!.count != 0) {
//								for photo in photos! {
//									thumbnails.append(photo["thumbnail"] as! PFFile)
//								}
//								//self.eventWithPhotos.removeAll(keepCapacity: true)
//								// self.eventWithPhotos[event.objectId!] = thumbnails
//								
//							}
//								
//							else {
//								
//								//self.eventWithPhotos.removeAll(keepCapacity: true)
//								var thumbnails: [PFFile] = []
//								// self.eventWithPhotos[event.objectId!] = thumbnails
//								
//							}
//							dispatch_async(dispatch_get_main_queue()) {
//								self.tableView.reloadData()
//							}
//							
//						})
//					}
//				}
//			} else {
//				print(error)
//			}
//		})
		
	}
	
	
}