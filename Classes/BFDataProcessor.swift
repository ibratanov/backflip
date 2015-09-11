//
//  BFDataProcessor.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import CoreData
import Parse
import MagicalRecord
import Foundation


class BFDataProcessor
{

	static let sharedProcessor = BFDataProcessor()
	
	
	func processEvents(events: [PFObject], completion: () -> Void)
	{
		if (events.count < 1) {
			return
		}
		
		let context = NSManagedObjectContext.MR_defaultContext()
		context.saveWithBlock({ (context) -> Void in
			
			for object : PFObject in events {
			
				let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId) as! Event;
				if (object.createdAt != nil) {
					event.createdAt = object.createdAt
				}
			
				if (object.updatedAt != nil) {
					event.updatedAt = object.updatedAt
				}
			
				if (self.isValid(object["eventName"])) {
					event.name = object["eventName"] as? String
				}
				
				if (self.isValid(object["isLive"])) {
					event.live = NSNumber(bool: (object["isLive"] as! Bool))
				}
				
				if (self.isValid(object["venue"])) {
					event.venue = object["venue"] as? String
				}

				if (self.isValid(object["startTime"])) {
					event.startTime = object["startTime"] as? NSDate
				}
				
				if (self.isValid(object["endTime"])) {
					event.endTime = object["endTime"] as? NSDate
				}

				if (self.isValid(object["geoLocation"])) {
					let geoObject = object["geoLocation"] as? PFGeoPoint
					if (geoObject != nil) {
						
						let attributes = ["latitude" : NSNumber(double: geoObject!.latitude), "longitude": NSNumber(double: geoObject!.longitude)]
						let geoPoint : GeoPoint = GeoPoint.fetchOrCreateWithAttributesAndValues(attributes) as! GeoPoint
						event.geoLocation = geoPoint;
					}
				}

			}
		}, completion: { (contextDidSave, error) -> Void in
			return completion()
		})
		
	}

	
	func processAttendees(attendees: [PFObject], completion: () -> Void)
	{
		if (attendees.count < 1) {
			return
		}
		
		let context = NSManagedObjectContext.MR_defaultContext()
		context.saveWithBlock({ (context) -> Void in
			
			for object : PFObject in attendees {
				
				let attendee : Attendance = Attendance.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId) as! Attendance
				if (object.createdAt != nil) {
					attendee.createdAt = object.createdAt
				}

				if (object.updatedAt != nil) {
					attendee.updatedAt = object.updatedAt
				}
				
				if (self.isValid(object["attendeeID"])) {
					attendee.attendeeId = object["attendeeID"] as? String
				}
				
				if (self.isValid(object["event"])) {
					let eventObject : PFObject = object["event"] as! PFObject
					let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: eventObject.objectId) as! Event
					attendee.event = event;
				}
				
			}
		}, completion: { (contextDidSave, error) -> Void in
			return completion()
		})
		
	}
	
	
	func processPhotos(photos: [PFObject], completion: () -> Void)
	{
		if (photos.count < 1) {
			return
		}
		
		let context = NSManagedObjectContext.MR_defaultContext()
		context.saveWithBlock({ (context) -> Void in
			
			for object : PFObject in photos {
			
				let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId) as! Photo;
				if (object.createdAt != nil) {
					photo.createdAt = object.createdAt
				}

				if (object.updatedAt != nil) {
					photo.updatedAt = object.updatedAt
				}
				
				photo.caption = object["caption"] as? String
				photo.flagged = object["flagged"] as? NSNumber
				photo.reporter = object["reporter"] as? String
				photo.uploader = object["uploader"] as? String
				photo.upvoteCount = object["upvoteCount"] as? NSNumber
				
				if (self.isValid(object["usersLiked"])) {
					let likedArray = object["usersLiked"] as? [String]
					photo.usersLiked = ",".join(likedArray!)
				}
				
				
				if (self.isValid(object["event"])) {
					let eventObject = object["event"] as? PFObject
					if (eventObject != nil) {
						let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: eventObject!.objectId!) as! Event
						photo.event = event;
					}
				}


				if (self.isValid(object["image"])) {
					let imageObject = object["image"] as? PFFile
					if (imageObject != nil) {
						let file : File = File.fetchOrCreateWhereAttribute("url", isValue: imageObject?.url) as! File
						photo.image = file;
					}
				}

				if (self.isValid(object["thumbnail"])) {
					let imageObject = object["thumbnail"] as? PFFile
					if (imageObject != nil) {
						let file : File = File.fetchOrCreateWhereAttribute("url", isValue: imageObject?.url) as! File
						photo.thumbnail = file;
					}
				}

			}
		}, completion: { (contextDidSave, error) -> Void in
			return completion()
		})
	}
	
	
	
	func isValid(value: AnyObject?) -> Bool
	{
		if (value == nil) {
			return false
		}
		
		if (value?.isKindOfClass(NSNull) == true) {
			return false
		}
		
		return true
	}


	
	func save(block: (context: NSManagedObjectContext) -> Void, completionHandler:(contextDidSave: Bool, error: NSError) -> Void)
	{
		let context = NSManagedObjectContext.MR_rootSavingContext()
		context.performBlock { () -> Void in
			block(context: context)
			
			context.saveWithOptions(1, completion: { (didSave, err) -> Void in
				// completionHandler(contextDidSave: true, error: nil);
			})
			
		}
	}
	
}