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
	static let sharedDelegate = BFTabBarControllerDelegate()
	
	func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
	{
		let selectedIndex = tabBarController.viewControllers?.indexOf(viewController)
		if (selectedIndex == 1) {
			
			let currentEvent: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id")
			if (currentEvent == nil) {
				var alertController = UIAlertController(title: "Take Photo", message: "Please check in or create an event before uploading photos.", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (alertAction) -> Void in

					if UIApplication.sharedApplication().windows.first!.rootViewController as? UITabBarController != nil {
						var tababarController = (UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController
						tababarController.selectedIndex = 0
					}
					
				}))
				
				let window : UIWindow? = UIApplication.sharedApplication().windows.first! as? UIWindow
				window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
			} else {
				
				var event = Event()
				event.objectId = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id") as? String
				event.name = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_name") as? String
			
				displayCamera(event)

			}
			
			return false
		}
		
		return true
	}
	
	
    func displayCamera(event: Event)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        var customCameraFCF = storyboard.instantiateViewControllerWithIdentifier("customCameraFCF") as! CustomCamera
        customCameraFCF.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        let window : UIWindow? = UIApplication.sharedApplication().windows.first! as? UIWindow
        window?.rootViewController!.presentViewController(customCameraFCF, animated: true, completion: nil)
        
    }
	
}
