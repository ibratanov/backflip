//
//  BFTabBarControllerDelegate.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-12.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class BFTabBarControllerDelegate : NSObject, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	static let sharedDelegate = BFTabBarControllerDelegate()
	
	func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
	{
		let selectedIndex = tabBarController.viewControllers?.indexOf(viewController)
		if (selectedIndex == 1) {
			
			let currentEvent: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id")
			if (currentEvent == nil) {
				var alertController = UIAlertController(title: "Take Photo", message: "Please checkin or create an event before upload photos", preferredStyle: .Alert)
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
		
		var testCamera = CustomCamera()
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
			
			testCamera.event = event
			
			testCamera.delegate = self
			testCamera.modalPresentationStyle = UIModalPresentationStyle.FullScreen
			testCamera.sourceType = .Camera
			testCamera.allowsEditing = false
			testCamera.showsCameraControls = false
			testCamera.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0)
			testCamera.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0, 71.0), 1.333333, 1.333333)
			
			let window : UIWindow? = UIApplication.sharedApplication().windows.first! as? UIWindow
			window?.rootViewController!.presentViewController(testCamera, animated: true, completion: nil)
		}
		
	}
	
}
