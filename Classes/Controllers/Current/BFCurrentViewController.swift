//
//  BFCurrentViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-23.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Parse
import Foundation


class BFCurrentViewController : UIViewController
{
	
	override func loadView()
	{
		super.loadView()
		
		let checkinTime = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_time") as? NSDate
		if (checkinTime != nil) {
			
			// check for current event
			let config = PFConfig.currentConfig()
			var checkoutDelay = 8
			if (config["checkout_timeout"] != nil) {
				checkoutDelay = Int(config["checkout_timeout"] as! NSNumber)
			}
			
			let expiryTime = checkinTime?.addHours(Int(checkoutDelay))
			if (expiryTime != nil && NSDate().isGreaterThanDate(expiryTime!)) {
				NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
				NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
				NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_name")
			}
		}

	}
	
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		let event = self.currentEvent()
		if (event != nil) {
			let storyboard = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
			let eventAlbumViewController = storyboard.instantiateViewControllerWithIdentifier("EventAlbumViewController") as! EventAlbumViewController
			eventAlbumViewController.event = event
			eventAlbumViewController.currentEvent = true
			self.navigationController?.setViewControllers([eventAlbumViewController], animated: false)
		}
	}
	
	
	private func currentEvent() -> Event?
	{
		let eventId = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id") as? String
		if (eventId != nil) {
			return Event.MR_findFirstByAttribute("objectId", withValue: eventId!)
		}
		
		return nil
	}
	
	
}
