//
//  NSDate+Extensions.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-24.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation



let kMinute = 60
let kDay = kMinute * 24
let kWeek = kDay * 7
let kMonth = kDay * 31
let kYear = kDay * 365

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



func NSDateTimeAgoLocalizedStrings(key: String) -> String
{
	return key
//	let resourcePath = NSBundle.mainBundle().resourcePath
//	let path = resourcePath?.stringByAppendingPathComponent("NSDateTimeAgo.bundle")
//	let bundle = NSBundle(path: path!)
//	
//	return NSLocalizedString(key, tableName: "NSDateTimeAgo", bundle: bundle!, comment: "")
}

extension NSDate {
	
	// shows 1 or two letter abbreviation for units.
	// does not include 'ago' text ... just {value}{unit-abbreviation}
	// does not include interim summary options such as 'Just now'
	var timeAgoSimple: String {
		
		let now = NSDate()
		let deltaSeconds = Int(fabs(timeIntervalSinceDate(now)))
		let deltaMinutes = deltaSeconds / 60
		
		var value: Int!
		
		if deltaSeconds < kMinute {
			// Seconds
			return stringFromFormat("%%d%@s", withValue: deltaSeconds)
		} else if deltaMinutes < kMinute {
			// Minutes
			return stringFromFormat("%%d%@m", withValue: deltaMinutes)
		} else if deltaMinutes < kDay {
			// Hours
			value = Int(floor(Float(deltaMinutes / kMinute)))
			return stringFromFormat("%%d%@h", withValue: value)
		} else if deltaMinutes < kWeek {
			// Days
			value = Int(floor(Float(deltaMinutes / kDay)))
			return stringFromFormat("%%d%@d", withValue: value)
		} else if deltaMinutes < kMonth {
			// Weeks
			value = Int(floor(Float(deltaMinutes / kWeek)))
			return stringFromFormat("%%d%@w", withValue: value)
		} else if deltaMinutes < kYear {
			// Month
			value = Int(floor(Float(deltaMinutes / kMonth)))
			return stringFromFormat("%%d%@mo", withValue: value)
		}
		
		// Years
		value = Int(floor(Float(deltaMinutes / kYear)))
		return stringFromFormat("%%d%@yr", withValue: value)
	}
	
	var timeAgo: String {
		
		let now = NSDate()
		let deltaSeconds = Int(fabs(timeIntervalSinceDate(now)))
		let deltaMinutes = deltaSeconds / 60
		
		var value: Int!
		
		if deltaSeconds < 5 {
			// Just Now
			return NSDateTimeAgoLocalizedStrings("Just now")
		} else if deltaSeconds < kMinute {
			// Seconds Ago
			return stringFromFormat("%%d %@seconds ago", withValue: deltaSeconds)
		} else if deltaSeconds < 120 {
			// A Minute Ago
			return NSDateTimeAgoLocalizedStrings("A minute ago")
		} else if deltaMinutes < kMinute {
			// Minutes Ago
			return stringFromFormat("%%d %@minutes ago", withValue: deltaMinutes)
		} else if deltaMinutes < 120 {
			// An Hour Ago
			return NSDateTimeAgoLocalizedStrings("An hour ago")
		} else if deltaMinutes < kDay {
			// Hours Ago
			value = Int(floor(Float(deltaMinutes / kMinute)))
			return stringFromFormat("%%d %@hours ago", withValue: value)
		} else if deltaMinutes < (kDay * 2) {
			// Yesterday
			return NSDateTimeAgoLocalizedStrings("Yesterday")
		} else if deltaMinutes < kWeek {
			// Days Ago
			value = Int(floor(Float(deltaMinutes / kDay)))
			return stringFromFormat("%%d %@days ago", withValue: value)
		} else if deltaMinutes < (kWeek * 2) {
			// Last Week
			return NSDateTimeAgoLocalizedStrings("Last week")
		} else if deltaMinutes < kMonth {
			// Weeks Ago
			value = Int(floor(Float(deltaMinutes / kWeek)))
			return stringFromFormat("%%d %@weeks ago", withValue: value)
		} else if deltaMinutes < (kDay * 61) {
			// Last month
			return NSDateTimeAgoLocalizedStrings("Last month")
		} else if deltaMinutes < kYear {
			// Month Ago
			value = Int(floor(Float(deltaMinutes / kMonth)))
			return stringFromFormat("%%d %@months ago", withValue: value)
		} else if deltaMinutes < (kDay * (kYear * 2)) {
			// Last Year
			return NSDateTimeAgoLocalizedStrings("Last Year")
		}
		
		// Years Ago
		value = Int(floor(Float(deltaMinutes / kYear)))
		return stringFromFormat("%%d %@years ago", withValue: value)
		
	}
	
	var timeTogo: String {
		
		let now = NSDate()
		let deltaSeconds = Int(fabs(timeIntervalSinceDate(now)))
		let deltaMinutes = deltaSeconds / 60
		
		var value: Int!
		
		if deltaSeconds < 5 {
			// Just Now
			return NSDateTimeAgoLocalizedStrings("Just now")
		} else if deltaSeconds < kMinute {
			// Seconds Ago
			return stringFromFormat("%%d %@seconds", withValue: deltaSeconds)
		} else if deltaSeconds < 120 {
			// A Minute Ago
			return NSDateTimeAgoLocalizedStrings("A minute")
		} else if deltaMinutes < kMinute {
			// Minutes Ago
			return stringFromFormat("%%d %@minutes ago", withValue: deltaMinutes)
		} else if deltaMinutes < 120 {
			// An Hour Ago
			return NSDateTimeAgoLocalizedStrings("An hour")
		} else if deltaMinutes < kDay {
			// Hours Ago
			value = Int(floor(Float(deltaMinutes / kMinute)))
			return stringFromFormat("%%d %@hours ", withValue: value)
		} else if deltaMinutes < (kDay * 2) {
			// Yesterday
			return NSDateTimeAgoLocalizedStrings("Tomorrow")
		} else if deltaMinutes < kWeek {
			// Days Ago
			value = Int(floor(Float(deltaMinutes / kDay)))
			return stringFromFormat("%%d %@days", withValue: value)
		} else if deltaMinutes < (kWeek * 2) {
			// Last Week
			return NSDateTimeAgoLocalizedStrings("Next week")
		} else if deltaMinutes < kMonth {
			// Weeks Ago
			value = Int(floor(Float(deltaMinutes / kWeek)))
			return stringFromFormat("%%d %@weeks", withValue: value)
		} else if deltaMinutes < (kDay * 61) {
			// Last month
			return NSDateTimeAgoLocalizedStrings("Next month")
		} else if deltaMinutes < kYear {
			// Month Ago
			value = Int(floor(Float(deltaMinutes / kMonth)))
			return stringFromFormat("%%d %@months", withValue: value)
		} else if deltaMinutes < (kDay * (kYear * 2)) {
			// Last Year
			return NSDateTimeAgoLocalizedStrings("Next Year")
		}
		
		// Years Ago
		value = Int(floor(Float(deltaMinutes / kYear)))
		return stringFromFormat("%%d %@years", withValue: value)
		
	}

	
	func stringFromFormat(format: String, withValue value: Int) -> String {
		
		let localeFormat = String(format: format, getLocaleFormatUnderscoresWithValue(Double(value)))
		
		return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
	}
	
	func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
		
		let localeCode = NSLocale.preferredLanguages().first!
		
		if localeCode == "fr" {
			let XY = Int(floor(value)) % 100
			let Y = Int(floor(value)) % 10
			
			if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
				return ""
			}
			
			if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
				return "_"
			}
			
			if Y == 1 && XY != 11 {
				return "__"
			}
		}
		
		return ""
	}
	
}