//
//  BFTabBarControllerDelegate.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-12.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class BFTabBarControllerDelegate : NSObject, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FastttCameraDelegate
{
	static let sharedDelegate = BFTabBarControllerDelegate.init()
	
	weak var _camera : CustomCamera?
	
	
	
	override init()
	{
		weak var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
		_camera = storyboard?.instantiateViewControllerWithIdentifier("customCameraFCF") as? CustomCamera
	}
	
	
	func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
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
	
    func displayCamera(event: Event)
    {
		_camera?.event = event
        _camera?.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        let window : UIWindow? = UIApplication.sharedApplication().windows.first!
        window?.rootViewController!.presentViewController(_camera!, animated: true, completion: nil)
        
    }
	
}
