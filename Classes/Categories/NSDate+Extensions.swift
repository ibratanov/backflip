//
//  NSDate+Extensions.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Foundation


extension NSDate
{
	func isGreaterThanDate(dateToCompare : NSDate) -> Bool
	{
		//Declare Variables
		var isGreater = false
		
		//Compare Values
		if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
		{
			isGreater = true
		}
		
		//Return Result
		return isGreater
	}
	
	
	func isLessThanDate(dateToCompare : NSDate) -> Bool
	{
		//Declare Variables
		var isLess = false
		
		//Compare Values
		if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
		{
			isLess = true
		}
		
		//Return Result
		return isLess
	}
	
	
	
	func addDays(daysToAdd : Int) -> NSDate
	{
		let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
		let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
		
		//Return Result
		return dateWithDaysAdded
	}
	
	
	func addHours(hoursToAdd : Int) -> NSDate
	{
		let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
		let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
		
		//Return Result
		return dateWithHoursAdded
	}
}
