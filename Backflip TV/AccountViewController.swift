//
//  AccountViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Foundation

class AccountViewController : UIViewController
{
	
	/**
	 * Account ID
	*/
	@IBOutlet weak var accountIdLabel : UILabel!
	
	
	/**
	 * Account full name
	*/
	@IBOutlet weak var accountNameLabel : UILabel!
	
	
	/**
	 * Account phone number
	*/
	@IBOutlet weak var accountPhoneNumber : UILabel!
	
	
	/**
	 * Account Logout
	*/
	@IBAction func logout()
	{
		NSUserDefaults.standardUserDefaults().removeObjectForKey("account.objectId")
		NSUserDefaults.standardUserDefaults().removeObjectForKey("account.fullName")
		NSUserDefaults.standardUserDefaults().removeObjectForKey("account.phoneNumber")
		NSUserDefaults.standardUserDefaults().synchronize()
		
		
		// Show login screen again..
		let storyboard = UIStoryboard(name: "Main-TV", bundle: NSBundle.mainBundle())
		let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
		
		let window = UIApplication.sharedApplication().windows.first
		if (window != nil) {
			window?.rootViewController?.presentViewController(loginViewController, animated: true, completion: nil)
		}
	}
	
	
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.accountIdLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("account.objectId") as? String
		self.accountNameLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("account.fullName") as? String
		self.accountPhoneNumber.text = NSUserDefaults.standardUserDefaults().objectForKey("account.phoneNumber") as? String
	}
}
