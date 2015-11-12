//
//  BFDataFetcher.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Parse
import Foundation


class BFDataFetcher : NSObject
{
	
	
	static let sharedFetcher = BFDataFetcher()
	
	
	func fetchData(activityInidactor: Bool)
	{
		ZAActivityBar.setLocationTabBar()
		
		if (activityInidactor) {
			#if os(iOS)
				ZAActivityBar.showWithStatus("Fetching Data", forAction: "data_loading")
			#endif
		}
		
		
		// Query the cloud
		PFCloud.callFunctionInBackground("query_databaseUpdate", withParameters: self.cloudCodeParameters() as? [NSObject : AnyObject], block: { (object, error) -> Void in
			
			if (activityInidactor) {
				#if os(iOS)
					ZAActivityBar.showSuccessWithStatus("Data Fetched", forAction: "data_loading")
				#endif
			}
			
			
			let priority = DISPATCH_QUEUE_PRIORITY_HIGH
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let objects: AnyObject? = object?.objectForKey("Event")
				if (objects?.count > 0) {
					if (activityInidactor) {
						#if os(iOS)
							ZAActivityBar.showWithStatus("Processing Events", forAction: "process_events")
						#endif
					}
				
					BFDataProcessor.sharedProcessor.processEvents(objects as? [PFObject], completion: { () -> Void in
						if (activityInidactor) {
							#if os(iOS)
								ZAActivityBar.showSuccessWithStatus("Events Processed", forAction: "process_events")
							#endif
						}
						
						NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: nEventObjectsUpdated, object: nil))
					})
				}
				
			}
			
			
			// Event Attendance
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let objects: AnyObject? = object?.objectForKey("EventAttendance")
				if (objects?.count > 0) {
					if (activityInidactor) {
						#if os(iOS)
							ZAActivityBar.showWithStatus("Processing Attendees", forAction: "process_attendees")
						#endif
					}
					
					BFDataProcessor.sharedProcessor.processAttendees(objects as? [PFObject], completion: { () -> Void in
						if (activityInidactor) {
							#if os(iOS)
								ZAActivityBar.showSuccessWithStatus("Attendees Processed", forAction: "process_attendees")
							#endif
						}
					})
				}
				
			}
			
			
			// Photos
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let objects: AnyObject? = object?.objectForKey("Photo")
				if (objects?.count > 0) {
					if (activityInidactor) {
						#if os(iOS)
							ZAActivityBar.showWithStatus("Processing Photos", forAction: "process_photos")
						#endif
					}
					
					BFDataProcessor.sharedProcessor.processPhotos(objects as? [PFObject], completion: { () -> Void in
						if (activityInidactor) {
							#if os(iOS)
								ZAActivityBar.showSuccessWithStatus("Photos Processed", forAction: "process_photos")
							#endif
						}
						
						NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: nPhotoObjectsUpdated, object: nil))
					})
				}
				
			}
			
			// Event Features
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				let objects: AnyObject? = object?.objectForKey("EventFeature")
				if (objects?.count > 0) {
					if (activityInidactor) {
						#if os(iOS)
							ZAActivityBar.showWithStatus("Processing Featured Events", forAction: "process_features")
						#endif
					}
					
					BFDataProcessor.sharedProcessor.processEventFeatures(objects as? [PFObject], completion: { () -> Void in
						if (activityInidactor) {
							#if os(iOS)
								ZAActivityBar.showSuccessWithStatus("Featured Events Processed", forAction: "process_features")
							#endif
						}
					})
				}
				
			}
			
			
		})
		
	}
	
	
	
	func fetchDataInBackground(completion: (completed : Bool) -> Void)
	{
		// Query the cloud
		PFCloud.callFunctionInBackground("query_databaseUpdate", withParameters: self.cloudCodeParameters() as? [NSObject : AnyObject], block: { (object, error) -> Void in
			
			let priority = DISPATCH_QUEUE_PRIORITY_HIGH
			dispatch_async(dispatch_get_global_queue(priority, 0)) {
				
				let photos : AnyObject? = object?.objectForKey("Photo")
				let events : AnyObject? = object?.objectForKey("Event")
				let attendance : AnyObject? = object?.objectForKey("EventAttendance")
				
				
				BFDataProcessor.sharedProcessor.processEvents(events as? [PFObject], completion: { () -> Void in
					BFDataProcessor.sharedProcessor.processAttendees(attendance as? [PFObject], completion: { () -> Void in
						BFDataProcessor.sharedProcessor.processPhotos(photos as? [PFObject], completion: { () -> Void in
							return completion(completed: true)
						})
					})
				})
				
			}
			
		});
	}
	
	
	
	

	// --------------------------------------------------
	// MARK: Parameters
	// --------------------------------------------------
	
	func cloudCodeParameters() -> AnyObject
	{
		let parameters = NSMutableDictionary()
		
		let lastUpdated = NSMutableDictionary()
		let classNames : [String] = ["Event", "Photo", "Attendance"]
		let parseClassNames : [String] = ["Event", "Photo", "EventAttendance"]
		for className: String in classNames {
			let updated : NSDate = self.lastUpdated(className)
			lastUpdated.setObject(updated, forKey: parseClassNames[classNames.indexOf(className)!])
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
		let objectType : AnyObject.Type = NSClassFromString(className)!
		let object : NSManagedObject.Type = objectType as! NSManagedObject.Type
		let coreObject = object.MR_findFirstOrderedByAttribute("updatedAt", ascending: false)
		if (coreObject != nil) {
			let parseObject : ParseObject = coreObject as! ParseObject
			if (parseObject.updatedAt != nil) {
				return parseObject.updatedAt!
			}
		}
		
		return NSDate.distantPast() 
	}
	
	
}