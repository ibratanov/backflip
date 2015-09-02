//
//  BFDataFetcher.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Parse
import Foundation


class BFDataFetcher : NSObject {
	
	
	static let sharedFetcher = BFDataFetcher()
	
	
	func fetchData(activityInidactor: Bool)
	{
		if (activityInidactor) {
			ZAActivityBar.showWithStatus("Fetching Data", forAction: "data_loading")
		}
		
		
		// Query the cloud
		PFCloud.callFunctionInBackground("query_databaseUpdate", withParameters: self.cloudCodeParameters() as? [NSObject : AnyObject], block: { (object, error) -> Void in
			
			if (activityInidactor) {
				ZAActivityBar.showSuccessWithStatus("Data Fetched", forAction: "data_loading")
			}
			
			
			let priority = DISPATCH_QUEUE_PRIORITY_HIGH
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let objects: AnyObject? = object?.objectForKey("Event")
				if (objects?.count > 0) {
					if (activityInidactor) {
						ZAActivityBar.showWithStatus("Processing Events", forAction: "process_events")
					}
				
					BFDataProcessor.sharedProcessor.processEvents(objects as! [PFObject], completion: { () -> Void in
						if (activityInidactor) {
							ZAActivityBar.showSuccessWithStatus("Events Processed", forAction: "process_events")
						}
					})
				}
				
			}
			
			
			// Event Attendance
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let objects: AnyObject? = object?.objectForKey("EventAttendance")
				if (objects?.count > 0) {
					if (activityInidactor) {
						ZAActivityBar.showWithStatus("Processing Attendees", forAction: "process_attendees")
					}
					
					BFDataProcessor.sharedProcessor.processAttendees(objects as! [PFObject], completion: { () -> Void in
						if (activityInidactor) {
							ZAActivityBar.showSuccessWithStatus("Attendees Processed", forAction: "process_attendees")
						}
					})
				}
				
			}
			
			
			// Photos
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let objects: AnyObject? = object?.objectForKey("Photo")
				if (objects?.count > 0) {
					if (activityInidactor) {
						ZAActivityBar.showWithStatus("Processing Photos", forAction: "process_photos")
					}
					
					BFDataProcessor.sharedProcessor.processPhotos(objects as! [PFObject], completion: { () -> Void in
						if (activityInidactor) {
							ZAActivityBar.showSuccessWithStatus("Photos Processed", forAction: "process_photos")
						}
					})
				}
				
			}
			
			
			
		})
		
	}
	
	
	
	

	// --------------------------------------------------
	// MARK: Parameters
	// --------------------------------------------------
	
	func cloudCodeParameters() -> AnyObject
	{
		let parameters = NSMutableDictionary()
		
		let lastUpdated = NSMutableDictionary()
		let classNames : [String] = ["Event", "Photo"]
		for className: String in classNames {
			let updated : NSDate = self.lastUpdated(className)
			lastUpdated.setObject(updated, forKey: className)
		}
		
		if (PFUser.currentUser() != nil) {
			parameters.setObject(PFUser.currentUser()!.objectId!, forKey: "userId")
		}
		
		parameters.setObject(lastUpdated, forKey: "lastUpdated")
		parameters.setObject(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!, forKey: "appVersion")
		
		return parameters
	}
	

	func lastUpdated(className: String) -> NSDate
	{
		let objectType : AnyObject.Type = NSClassFromString(className)
		let object : NSManagedObject.Type = objectType as! NSManagedObject.Type
		let coreObject = object.MR_findFirstOrderedByAttribute("updatedAt", ascending: false)
		if (coreObject != nil) {
			let parseObject : ParseObject = coreObject as! ParseObject
			return parseObject.updatedAt!
		}
		
		return NSDate.distantPast() as! NSDate
	}
	
	
}