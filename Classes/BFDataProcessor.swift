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
			
				var event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId) as! Event;
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
					event.live = object["eventName"] as? NSNumber
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
					var geoObject = object["geoLocation"] as? PFGeoPoint
					if (geoObject != nil) {
						
						var attributes = ["latitude" : NSNumber(double: geoObject!.latitude), "longitude": NSNumber(double: geoObject!.longitude)]
						var geoPoint : GeoPoint = GeoPoint.fetchOrCreateWithAttributesAndValues(attributes) as! GeoPoint
						event.geoLocation = geoPoint;
					}
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
			
				var photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId) as! Photo;
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
				photo.usersLiked = object["usersLiked"] as? String
				
				
				if (self.isValid(object["event"])) {
					var eventObject = object["event"] as? PFObject
					if (eventObject != nil) {
						var event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: eventObject!.objectId!) as! Event
						photo.event = event;
					}
				}


				if (self.isValid(object["image"])) {
					var imageObject = object["image"] as? PFFile
					if (imageObject != nil) {
						var file : File = File.fetchOrCreateWhereAttribute("url", isValue: imageObject?.url) as! File
						photo.image = file;
					}
				}

				if (self.isValid(object["thumbnail"])) {
					var imageObject = object["thumbnail"] as? PFFile
					if (imageObject != nil) {
						var file : File = File.fetchOrCreateWhereAttribute("url", isValue: imageObject?.url) as! File
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
		let context = NSManagedObjectContext.MR_defaultContext()
		context.performBlock { () -> Void in
			block(context: context)
			
			context.saveWithOptions(1, completion: { (didSave, err) -> Void in
				// completionHandler(contextDidSave: true, error: nil);
			})
			
		}
	}
	
}