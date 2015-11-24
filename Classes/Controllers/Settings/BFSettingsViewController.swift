//
//  BFSettingsViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-23.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Parse
import DigitsKit
import Foundation

class BFSettingsViewController : UITableViewController
{
	
	
	@available(iOS 2.0, *)
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		// Section '0'
		if (indexPath.section == 0 && indexPath.row == 0) { // Facebook
			self.openUrl(NSURL(string: "https://www.facebook.com/getbackflip/")!)
		} else if (indexPath.section == 0 && indexPath.row == 1) { // Twitter
			self.openUrl(NSURL(string: "https://twitter.com/getbackflip")!)
		} else if (indexPath.section == 0 && indexPath.row == 2) { // Contact Us
			Instabug.invokeFeedbackSenderViaEmail()
		}
		
		// Section '1'
		if (indexPath.section == 1 && indexPath.row == 0) { // Privacy
			self.openUrl(NSURL(string: "http://getbackflip.com/privacy")!)
		} else if (indexPath.section == 1 && indexPath.row == 1) { // Terms & confitions
			self.openUrl(NSURL(string: "http://getbackflip.com/eula")!)
		}
		
		// Section '2'
		if (indexPath.section == 2 && indexPath.row == 0) { // Logout
			self.logout()
		}
	}
	
	
	
	
	// ----------------------------------------
	//  MARK: - URL opening
	// ----------------------------------------
	
	private func openUrl(url: NSURL)
	{
		if #available(iOS 9.0, *) {
			let safariViewController = SFSafariViewController(URL: url)
			self.presentViewController(safariViewController, animated: true, completion: nil)
		} else {
			let webViewController = BFWebviewController()
			webViewController.loadUrl(url)
			let navigationController = UINavigationController(rootViewController: webViewController)
			self.presentViewController(navigationController, animated: true, completion: nil)
		}
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Logout
	// ----------------------------------------
	
	private func logout()
	{
		let alertController = UIAlertController(title: "Logout", message:"Are you sure you want to logout?", preferredStyle: .ActionSheet)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { (alertAction) -> Void in
			PFUser.logOut()
			
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
			NSUserDefaults.standardUserDefaults().synchronize()
			
			BFBonjourManager.sharedManager.stopServiceDiscovery()
			
			FBSDKLoginManager().logOut()
			FBSDKAccessToken.setCurrentAccessToken(nil)
			
			Digits.sharedInstance().logOut()
			
			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				let onboardingViewController = BFOnboardingViewController()
				if let window = UIApplication.sharedApplication().windows.first {
					
					let transition = CATransition()
					transition.startProgress = 0.0
					transition.endProgress = 1.0
					transition.type = "flip" // kCATransitionPush
					transition.subtype = "fromRight"
					transition.duration = 0.4
					
					window.setRootViewController(onboardingViewController, transition: transition)
					
				}
			}
			
		}))
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
}
