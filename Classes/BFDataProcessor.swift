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
		return BFDataWrapper.processEvents(events, completion: completion)
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
		return BFDataWrapper.processPhotos(photos, completion: completion)
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