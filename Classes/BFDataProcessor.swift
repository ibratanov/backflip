//
//  BFDataProcessor.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Parse
import CoreData
import MagicalRecord
import Foundation


class BFDataProcessor
{

	static let sharedProcessor = BFDataProcessor()


	func processEvents(events: [PFObject]?, completion: () -> Void)
	{
		if (events == nil || events!.count < 1) {
			return completion()
		}

		MagicalRecord.saveWithBlockAndWait { (localContext) -> Void in
			
			for object : PFObject in events! {
				
				let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId, inContext:localContext) as! Event;
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
				
				if (self.isValid(object["owner"])) {
					let ownerObject : PFObject = object["owner"] as! PFObject
					event.owner = ownerObject.objectId
				}
				
				if (self.isValid(object["enabled"])) {
					event.enabled = NSNumber(bool: (object["enabled"] as! Bool))
				}
				
				if (self.isValid(object["geoLocation"])) {
					let geoObject = object["geoLocation"] as? PFGeoPoint
					if (geoObject != nil) {
						
						let attributes = ["latitude" : NSNumber(double: geoObject!.latitude), "longitude": NSNumber(double: geoObject!.longitude)]
						let geoPoint : GeoPoint = GeoPoint.fetchOrCreateWithAttributesAndValues(attributes, inContext:localContext) as! GeoPoint
						event.geoLocation = geoPoint;
					}
				}
				
			}
			
		}
		
		return completion()
	}

	
	func processAttendees(attendees: [PFObject]?, completion: () -> Void)
	{
		if (attendees == nil || attendees?.count < 1) {
			return completion()
		}
		
		MagicalRecord.saveWithBlockAndWait { (localContext) -> Void in

			for object : PFObject in attendees! {
				
				let attendee : Attendance = Attendance.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId, inContext:localContext) as! Attendance
				if (object.createdAt != nil) {
					attendee.createdAt = object.createdAt
				}
				
				if (object.updatedAt != nil) {
					attendee.updatedAt = object.updatedAt
				}
				
				if (self.isValid(object["attendeeID"])) {
					attendee.attendeeId = object["attendeeID"] as? String
				}
				
				if (self.isValid(object["enabled"])) {
					attendee.enabled = NSNumber(bool: (object["enabled"] as! Bool))
				}
				
				if (self.isValid(object["event"])) {
					let eventObject : PFObject = object["event"] as! PFObject
					let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: eventObject.objectId, inContext:localContext) as! Event
					attendee.event = event;
				}
				
			}

		}
		
		return completion()
		
	}
	
	
	func processPhotos(photos: [PFObject]?, completion: () -> Void)
	{
		if (photos == nil || photos?.count < 1) {
			return completion()
		}
		
		
		MagicalRecord.saveWithBlockAndWait { (localContext) -> Void in
			
			for object : PFObject in photos! {
				
				let photo : Photo = Photo.fetchOrCreateWhereAttribute("objectId", isValue: object.objectId, inContext:localContext) as! Photo;
				if (object.createdAt != nil) {
					photo.createdAt = object.createdAt
				}
				
				if (object.updatedAt != nil) {
					photo.updatedAt = object.updatedAt
				}
				
				photo.caption = object["caption"] as? String
				if (self.isValid(object["flagged"])) {
					photo.flagged = NSNumber(bool: (object["flagged"] as! Bool))
				}
				photo.reporter = object["reporter"] as? String
				photo.uploader = object["uploader"] as? String
				photo.upvoteCount = object["upvoteCount"] as? NSNumber
				
				if (self.isValid(object["usersLiked"])) {
					let likedArray = object["usersLiked"] as? [String]
					photo.usersLiked = (likedArray!).joinWithSeparator(",")
				}
				
				if (self.isValid(object["enabled"])) {
					photo.enabled = NSNumber(bool: (object["enabled"] as! Bool))
				}
				
				if (self.isValid(object["event"])) {
					let eventObject = object["event"] as? PFObject
					if (eventObject != nil) {
						let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: eventObject!.objectId!, inContext:localContext) as! Event
						photo.event = event;
					}
				}
				
				
				if (self.isValid(object["image"])) {
					let imageObject = object["image"] as? PFFile
					if (imageObject != nil) {
						let file : File = File.fetchOrCreateWhereAttribute("url", isValue: imageObject?.url, inContext:localContext) as! File
						photo.image = file;
					}
				}
				
				if (self.isValid(object["thumbnail"])) {
					let imageObject = object["thumbnail"] as? PFFile
					if (imageObject != nil) {
						let file : File = File.fetchOrCreateWhereAttribute("url", isValue: imageObject?.url, inContext:localContext) as! File
						photo.thumbnail = file;
					}
				}
				
			}
			
		}
		
		return completion()
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
	
}