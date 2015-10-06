//
//  BFDataProcessor.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Parse
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
		return BFDataWrapper.processAttendance(attendees, completion: completion)
	}
	
	
	func processPhotos(photos: [PFObject]?, completion: () -> Void)
	{
		return BFDataWrapper.processPhotos(photos, completion: completion)
	}
	
}