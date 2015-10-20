//
//  BFLocationManager.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-05.
//  Copyright © 2015 Backflip. All rights reserved.
//


import Foundation
import CoreLocation


/**
 * Debugging
*/
#if DEBUG
	private let kLocationDebugging : Bool = true
#else
	private let kLocationDebugging : Bool = false
#endif



//------------------------------------
// MARK: BFLocationManager
//------------------------------------

public class BFLocationManager : NSObject, CLLocationManagerDelegate
{
	
	/**
	 * Singleton instance
	*/
	public static let sharedManager : BFLocationManager = BFLocationManager.init()
	
	
	/**
	* Completion blocks
	*/
	public typealias BFLocationUpdatedBlock = (location: CLLocation?, error: NSError?) -> Void
	
	public typealias BFAuthorizationStatusBlock = (status: CLAuthorizationStatus, error: NSError?) -> Void
	
	
	/**
	 * Internal location manager
	*/
	internal var locationManager = CLLocationManager()
	
	
	/**
	 * Requesting authorization
	*/
	internal var authorizationPending : Bool = false
	
	
	/**
	 * Location update pending
	*/
	internal var locationPending : Bool = false
	
	/**
	 * Internal block stoarge
	*/
	internal var authorizationBlock : BFAuthorizationStatusBlock?
	
	internal var locationBlock : BFLocationUpdatedBlock?
	
	
	/**
	 * Cached Location
	*/
	public var cachedLocation : CLLocation?
	
	
	
	override private init()
	{
		super.init()
		
		locationManager.delegate = self
	}
	
	
	
	//------------------------------------
	// MARK: Public methods
	//------------------------------------
	
	public func requestAuthorization(completion: BFAuthorizationStatusBlock?)
	{
		if (CLLocationManager.authorizationStatus() != .NotDetermined) {
			if (completion != nil) {
				return completion!(status: CLLocationManager.authorizationStatus(), error: nil)
			}
		} else {
			
			authorizationPending = true
			
			let hasAlwaysKey = (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil)
			let hasWhenInUseKey = (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil)
			if hasAlwaysKey == true {
				authorizationBlock = completion
				locationManager.requestAlwaysAuthorization()
			} else if hasWhenInUseKey == true {
				authorizationBlock = completion
				locationManager.requestWhenInUseAuthorization()
			} else {
				assert(false, "To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.")
			}
			
		}
	}
	
	
	public func fetchLocation(accuracy: Accuracy, completion: BFLocationUpdatedBlock?)
	{
		
		let status = CLLocationManager.authorizationStatus()
		if (status != .AuthorizedAlways && status != .AuthorizedWhenInUse) {
			print("📍📛 You need to request location authorization before requesting the users location.")
			
			if (completion != nil) {
				let error = NSError(domain: "com.getbackflip.location", code: 500, userInfo: [NSLocalizedDescriptionKey: "You need to request location authorization before requesting the users location."])
				return completion!(location: nil, error: error)
			}
		} else {
			
			if (locationPending == false) {
				
				if (kLocationDebugging == true) {
					print("📍👀 Fetching location..")
				}
				
				locationPending = true
				// locationManager.desiredAccuracy = accuracy.accuracyThreshold()
				
				locationBlock = completion
				
				
				#if SNAPSHOT
					let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
					dispatch_after(delayTime, dispatch_get_main_queue()) {
						let location = CLLocation(latitude: 43.64607355662625, longitude: -79.3959379037681)
						self.locationManager(self.locationManager, didUpdateLocations: [location])
					}
				#endif
				
				
				if (cachedLocation != nil) {
					locationBlock?(location: cachedLocation, error: nil)
				}
				
				
				if #available(iOS 9.0, *) {
					locationManager.requestLocation()
				} else {
					locationManager.startUpdatingLocation()
				}
			}
			
		}
		
	}
	

	

	//------------------------------------
	// MARK: Location Manager Delegate
	//------------------------------------
	
	public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
	{
		if (kLocationDebugging == true) {
			print("📍👀 Location authorization status changed, new state \(status.rawValue)")
		}
		
		locationPending = false
		
		if (authorizationBlock != nil) {
			authorizationBlock!(status: status, error: nil)
		}
		
		// Clear the location manager after authorization, this is an iOS 8 bug
		if (authorizationPending == true && (status == .AuthorizedAlways || status == .AuthorizedWhenInUse)) {
			authorizationPending = false
			locationManager = CLLocationManager()
			locationManager.delegate = self
		}
	}
	
	
	public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
	{
		if (kLocationDebugging == true) {
			print("📍👍🏼 Location updated, \(locations.first?.coordinate.latitude), \(locations.first?.coordinate.longitude)")
		}
		
		locationPending = false
		
		if (locationBlock != nil) {
			cachedLocation = locations.first
			locationBlock!(location: locations.first, error: nil)
		}
		
		if #available(iOS 9.0, *) {
			// Nothing todo on iOS 9 :)
		} else {
			locationManager.stopUpdatingLocation()
		}
		
	}
	
	public func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
	{
		if (kLocationDebugging == true) {
			print("📍📛 Location error, \(error)")
		}
		
		if (locationBlock != nil) {
			locationBlock!(location: nil, error: error)
		}
	}
	
	
	
}



/**
	Accuracy is used to set the minimum level of precision required during location discovery

	- None:         Unknown level detail
	- Country:      Country detail. It's used only for a single shot location request and uses IP based location discovery (no auth required). Inaccurate (>5000 meters, and/or received >10 minutes ago).
	- City:         5000 meters or better, and received within the last 10 minutes. Lowest accuracy.
	- Neighborhood: 1000 meters or better, and received within the last 5 minutes.
	- Block:        100 meters or better, and received within the last 1 minute.
	- House:        15 meters or better, and received within the last 15 seconds.
	- Room:         5 meters or better, and received within the last 5 seconds. Highest accuracy.
*/
public enum Accuracy:Int, CustomStringConvertible
{
	case None			= 0
	case Country		= 1
	case City			= 2
	case Neighborhood	= 3
	case Block			= 4
	case House			= 5
	case Room			= 6
	
	public var description: String {
		get {
			switch self {
			case .None:
				return "None"
			case .Country:
				return "Country"
			case .City:
				return "City"
			case .Neighborhood:
				return "Neighborhood"
			case .Block:
				return "Block"
			case .House:
				return "House"
			case .Room:
				return "Room"
			}
		}
	}
	
	/**
		This is the threshold of accuracy to validate a location
	
		- returns: value in meters
	*/
	func accuracyThreshold() -> Double {
		switch self {
		case .None:
			return Double.infinity
		case .Country:
			return Double.infinity
		case .City:
			return 5000.0
		case .Neighborhood:
			return 1000.0
		case .Block:
			return 100.0
		case .House:
			return 15.0
		case .Room:
			return 5.0
		}
	}
	
	/**
		Time threshold to validate the accuracy of a location
	
		- returns: in seconds
	*/
	func timeThreshold() -> Double {
		switch self {
		case .None:
			return Double.infinity
		case .Country:
			return Double.infinity
		case .City:
			return 600.0
		case .Neighborhood:
			return 300.0
		case .Block:
			return 60.0
		case .House:
			return 15.0
		case .Room:
			return 5.0
		}
	}
}