//
//  BFTabBarControllerDelegate.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-12.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation



public class BFTabBarControllerDelegate : NSObject, UITabBarControllerDelegate
{

	public static let sharedDelegate = BFTabBarControllerDelegate.init()

	/**
	 * Shared (internal) camera controller
	*/
	public static let cameraController = BFCameraController.sharedController

	
	
	override private init()
	{
		super.init()
	}
	
	
	public func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
	{
		let selectedIndex = tabBarController.viewControllers?.indexOf(viewController)
		if (selectedIndex == 1) {
			
			let currentEvent: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id")
			if (currentEvent == nil) {
				let alertController = UIAlertController(title: "Take Photo", message: "Please check in or create an event before uploading photos.", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (alertAction) -> Void in

					if UIApplication.sharedApplication().windows.first!.rootViewController as? UITabBarController != nil {
						let tababarController = (UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController
						tababarController.selectedIndex = 0
					}
					
				}))
				
				let window : UIWindow? = UIApplication.sharedApplication().windows.first!
				window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
			} else {
				
				let objectId = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id") as? String
				let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: objectId) as! Event
				displayCamera(event)

			}
			
			return false
		}
		
		return true
	}



	func displayCamera(event: Event?)
	{
		BFCameraController.sharedController.event = event
		BFCameraController.sharedController.presentCamera()
	}


	func displayImagePickerSheet(event: Event?)
	{
		BFCameraController.sharedController.event = event
		BFCameraController.sharedController.presentImagePickerSheet()
	}

}
