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
	}
	
}
